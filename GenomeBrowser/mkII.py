import os
import sys
import time
from multiprocessing import Process
from wikitools import wiki, category, page
import json

VCF_FILE = 'data/example.vcf'
OUTPUT_TEMPLATE = 'snpediaMap'
LOCAL_SNPEDIA = 'data/localsnpedia.json'
LOCAL_RSNUMS = 'data/localrsnums.txt'
NUM_OF_PROCESSES = 10

if(not os.path.isfile(LOCAL_SNPEDIA)):
	open(LOCAL_SNPEDIA,'w').write('{}')

''' Queries snpedia for all rsnums with entries in snpedia.
	Writes them to LOCAL_RSNUMS.
'''
def getRSinSNPedia():
	site = wiki.Wiki('http://bots.snpedia.com/api.php')
	snps = category.Category(site,'Is_a_snp')
	f = open(LOCAL_RSNUMS,'w')
	for article in snps.getAllMembersGen(namespaces=[0]):
		num = article.title.lower()
		if(num[:2] == 'rs'):
			f.write(num+'\n')
	f.close

'''	Returns all entries from VCF_FILE that have rsid that map to SNPedia
'''
def getVCFentries():
	ret = []
	if(not os.path.isfile(LOCAL_RSNUMS)):
		getRSinSNPedia()
	snps = {line[:-1]:0 for line in open(LOCAL_RSNUMS)}
	for line in open(VCF_FILE):
		if(line[0]!='#'):
			entry = line.split('\t')
			if(entry[2] in snps):
				ret.append(entry)
	return ret

''' Gets the genotype info as string from a vcf entry
'''
def getGenotype(entry):
	try:
		ref = entry[3]
		alt = entry[4]
		allele1 = entry[8][0]
		allele2 = entry[8][2]
		gt = list('(.;.)')
		if(allele1=='1'):
			gt[1]=alt
		if(allele1=='0'):
			gt[1]=ref
		if(allele2=='1'):
			gt[3]=alt
		if(allele2=='0'):
			gt[3]=ref
		if(gt[1]>gt[3]):
			gt[1],gt[3] = gt[3],gt[1]
		return ''.join(gt)
	except:
		return '(.;.)'

'''	Simple parser for rs(GT) SNPedia pages
'''
def genopageparser(pagestr):
	entries = pagestr.replace('{', '')
	entries = entries.replace('|', '')
	entries = entries.replace('}', '')
	entries = entries.split('\n')
	dictionary = {}
	for x in entries:
		if 'summary=' in x.lower():
				dictionary['phenotype'] = x[8:]
	return dictionary

'''	Simple parser for rs SNPedia pages
'''
def rspageparser(pagestr):
	entries = pagestr.replace('{', '')
	entries = entries.replace('|', '')
	entries = entries.replace('}', '')
	entries = entries.split('\n')
	dictionary = {}
	for x in entries:
		if 'gene=' in x[:5].lower():
			dictionary['gene'] = x[5:]
		if 'orientation=' in x[:12].lower():
			dictionary['orientation'] = x[12:]
		if 'summary=' in x[:8].lower():
			dictionary['description'] = x[8:]
		if 'id=' == x[:3].lower() and 'rs' not in x.lower():
			dictionary['omim'] = x[3:]
	return dictionary

''' Queries Snpedia/LOCAL_SNPEDIA for relevant info for all vcf entries in 
	entrylist. Writes findings to filename in json format. Used by mineSNPedia 
	to query snpedia/LOCAL_SNPEDIA in parrelel
'''
def snpediaQuery(filename,entrylist):
	site = wiki.Wiki('http://bots.snpedia.com/api.php')
	local = json.load(open(LOCAL_SNPEDIA,'rb'))
	json_dictionaries = []
	for entry in entrylist:
		GT = getGenotype(entry)
		if(entry[2]+GT not in local):
			rs_page = page.Page(site, entry[2]).getWikiText() 
			rsdict = rspageparser(rs_page)
			rsdict['genotype'] = GT
			rsdict['chromosome'] = entry[0]
			rsdict['position'] = entry[1]
			rsdict['rsid'] = entry[2]
			rsdict['url'] = 'http://www.snpedia.com/index.php/' + entry[2]
			try:
				geno_page = page.Page(site, entry[2]+GT).getWikiText()
				gtdict = genopageparser(geno_page)
				for key in gtdict:
					rsdict[key] = gtdict[key]
			except:
				pass
		else:
			rsdict = local[entry[2]+GT]
		json_dictionaries.append(rsdict)
	json.dump(json_dictionaries,open(filename,'wb'))

'''	funtion joins all data found by snpediaQuery calls.
	function is called at the end of mineSNPedia
	Writes to OUTPUT_TEMPLATE + '.json'
'''
def joinsnpfiles():
	alldata = []
	for x in range(NUM_OF_PROCESSES):
		filename = 'data/'+OUTPUT_TEMPLATE+str(x)+str('.json')
		data = json.load(open(filename,'rb'))
		for dic in data:
			alldata.append(dic)
		os.remove(filename)
	json.dump(alldata,open(OUTPUT_TEMPLATE+'.json','wb'))

''' Writes the findings to a local file for storage. This should greatly speed up subsequent runs.
'''
def storeLocal():
	data = json.load(open(OUTPUT_TEMPLATE+'.json','rb'))
	local = json.load(open(LOCAL_SNPEDIA,'rb'))
	for entry in data:
		local[entry['rsid']+entry['genotype']] = entry
	json.dump(local,open(LOCAL_SNPEDIA,'wb'))

'''	Master function that calls all other functions. Handles flow and multiprocessing
'''
def mineSNPedia():
	entries = getVCFentries()
	interval = float(len(entries)) / NUM_OF_PROCESSES
	diviedentries = [entries[int(round(x*interval)):int(round((x+1)*interval))] for x in range(NUM_OF_PROCESSES)]
	processlist = []
	for x in range(NUM_OF_PROCESSES):
		filename = 'data/'+OUTPUT_TEMPLATE+str(x)+'.json'
		p = Process(target = snpediaQuery, args = (filename,diviedentries[x]))
		p.start()
		processlist.append(p)
	for p in processlist:
		p.join()
	joinsnpfiles()
	storeLocal()

'''	Cleans out local data files LOCAL_RSNUMS and LOCAL_SNPEDIA
'''
def cleanLocal():
	os.remove(LOCAL_RSNUMS)
	open(LOCAL_SNPEDIA,'w').write('{}')

'''	Easy to use method that mimics functionality of main while being easy to
	call from other python scirpts
'''
def mineVCF(filename):
	VCF_FILE = filename
	mineSNPedia()

# Acts as a main when run from command line.
if(__name__=='__main__'):
	if(len(sys.argv)>1 and sys.argv[1]=='clean'):
		sys.stderr.write('Removing local Data....\n')
		cleanLocal()
		sys.stderr.write('Done.')
	else:
		if(len(sys.argv)>1):
			VCF_FILE = sys.argv[1]	
		t = time.time()
		sys.stdout.write('Start time - ' + str(time.strftime("%I:%M:%S"))+'\n')
		mineSNPedia()
		sys.stdout.write('Run time - '+str(int(round((time.time()-t)/60)))+'\n')
		sys.stdout.write('Done!\n')
		sys.stdout.write('You may now open the Xcode project to browse the data.\n')
