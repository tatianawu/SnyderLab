import sys
import pandas as pd

bugs = pd.read_excel('bugs_list_genus.xlsx', header=0)
bugs.set_index('SampleID', inplace=True)
ids = pd.read_excel('fiber_IDs.xlsx', header=0, convert_float=True)
ids.set_index('Subject ID', inplace=True)

def rename_cols():
	columns = {}
	names = set()
	duplicates = {}

	for column in bugs:
		s = column.split('_')
		s[0] = s[0][1:]
		if len(s[0]) == 2: s[0] = '0' + s[0]

		fiber = get_fiber_name(s)
		time_series = get_time_series(s)
		prefix = get_prefix(s[0])

		name = 'X{}_{}_60{}{}'.format(prefix, s[0], get_fiber(s[0], fiber), time_series)

		if name not in names:
			columns[column] = name
			names.add(name)
		else:
			if name in duplicates: duplicates[name] += 1
			else: duplicates[name] = 1
			columns[column] = '{} ({})'.format(name, duplicates[name])
	
	bugs.rename(index=str, columns=columns, inplace=True)
	writer = pd.ExcelWriter('bugs_list_genus_reformatted.xlsx')
	bugs.to_excel(writer)
	writer.save()

def get_fiber(ID, fiber):
	ID = int(ID)
	cols = ['Fiber used', 'Fiber used2', 'Fiber used3', 'Fiber used4']
	for idx, col in enumerate(cols):
		if ids.loc[ID, col] == fiber:
			return idx + 1

def get_fiber_name(col):
	if 'Arabinoxylan' in col:
		return 'arabinoxylan'
	elif 'SC' in col and 'Inulin' in col:
		return 'SC inulin'
	elif 'LC' in col and 'Inulin' in col:
		return 'LC inulin'
	elif 'Mix' in col:
		return 'mix'
	else:
		print(col)
		sys.exit('Fiber not found')

def get_time_series(col):
	if 'Baseline' in col:
		return 1
	elif '10' in col:
		return 2
	elif '20' in col:
		return 3
	elif '30' in col:
		return 4
	elif 'Washout' in col and 'D3' in col:
		return 5
	elif 'Washout' in col and 'D10' in col:
		return 6
	else:
		print(col)
		sys.exit('Time series not found')

def get_prefix(ID):
	seventy = ['1005', '1008', '1010', '1015']
	if ID in seventy: return '70'
	return '69'

if __name__ == '__main__':
	rename_cols()