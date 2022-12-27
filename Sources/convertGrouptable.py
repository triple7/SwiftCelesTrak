import requests as R
from bs4 import BeautifulSoup
import re

URL = "https://celestrak.org/NORAD/elements/"
page = R.get(URL)
soup = BeautifulSoup(page.content, 'html.parser')

tables = soup.find_all('table')
groups = []
T1 = tables[0]
columns = T1.find_all('td')
for c in columns:
	c1 = c.findChildren("td")
	for c2 in c1:
		c3 = c2.findChildren('a')[0]
		link = c3['href']
		groupName = str(link).split('=')[1].split('&')[0]
		if groupName not in groups:
			groups.append(groupName)


groupCases = [g.replace('-', '_') for g in groups]
groupStrings = [f'case {groupCases[i]}: return "{groups[i]}"' for i, g in enumerate(groupCases) if '-' in groups[i]]

groupCases = '\n'.join([f'case {g}' for g in groupCases])
groupStrings = '    public var id:String {\nswitch self {\n'+'\n'.join(groupStrings)+'\ndefault: return self.rawValue\n}\n}'
enumString = 'public enum CelesTrakGroup:String, CaseIterable, Identifiable {\n'
print(enumString, groupCases, '\n\n', groupStrings, '\n}\n')