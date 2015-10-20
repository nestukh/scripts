#!/bin/bash


# user here is 'server'

# check with
# crontab -e
# 46  *    *   *  *    bash /home/server/Scripts/rssfilter.sh


### installing requirements
# sudo apt-get install python-qt4 xvfb pcregrep python3-dev libqt4-dev python-pip python-qt4-dev build-essential python-lxml; sudo pip install --upgrade beautifulsoup4 requests #### selenium pyvirtualdisplay feedgenerator
# sudo update-ca-certificates --fresh
# sudo sed -i "s/^vm.min_free_kbytes.*$/vm.min_free_kbytes = 32768/g" /etc/sysctl.conf
# sudo sed -i "s/smsc95xx.turbo_mode=N//g" /boot/cmdline.txt; sudo sed -i '/rootfstype/ s/$/ smsc95xx.turbo_mode=N/' /boot/cmdline.txt
# sudo sed -i "/^avoid_safe_mode=.*$/d" /boot/config.txt; echo "avoid_safe_mode=1" | sudo tee -a /boot/config.txt > /dev/null
# sudo reboot && exit # then relogin of course

# sudo apt-get install -y lighttpd
# sudo lighty-enable-mod userdir
# sudo rm /var/www/html/index.lighttpd.html
# mkdir -p $HOME/public_html/RSSs
# sudo service lighttpd force-reload


# open port 8099 on your router for your server at port 80, then use a dyndns

# http://nestukh.uni.cx:8099/~server/RSSs/FEEDSITE_rss.xml




# be sure that cron is running using 'ps -ef | grep cron'
# if not, insert '/etc/init.d/cron start' in /etc/rc.local (Raspian distro)


export PATH=$PATH:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/bin:/usr/local/games:/usr/games:$HOME/Scripts:$HOME/Scripts/Dropbox-Uploader: # not included in crontab env
source $HOME/.bashrc




function RSSFiltering {
SITEURL="$1" EXCLUDETAGS="$2" INCLUDETAGS="$3" EXCLUDETITLES="$4" INCLUDETITLES="$5" INCLUDEPOSTTAGS="$6" EXCLUDEPOSTTAGS="$7" xvfb-run -a python - <<END
import os
import sys
import time
import codecs
from bs4 import BeautifulSoup
# # # from PyQt4.QtGui import *  
# # # from PyQt4.QtCore import *  
# # # from PyQt4.QtWebKit import *
import urllib2
import math
import re
import unicodedata
import getpass
from xml.etree import ElementTree as ET
from xml.dom import minidom
# # from selenium import webdriver
# # from selenium.webdriver.common.by import By
# # from selenium.webdriver.support.ui import WebDriverWait
# # from selenium.webdriver.support import expected_conditions as EC
# # from pyvirtualdisplay import Display

def touch(fname):
  if not os.path.exists(fname):
    open(fname, 'a').close()

# # # class Render(QWebPage):  
# # #   def __init__(self, url):  
# # #     self.app = QApplication(sys.argv)  
# # #     QWebPage.__init__(self)  
# # #     self.loadFinished.connect(self._loadFinished)  
# # #     self.mainFrame().load(QUrl(url))  
# # #     self.app.exec_()  
# # #   
# # #   def _loadFinished(self, result):  
# # #     self.frame = self.mainFrame()  
# # #     self.app.quit()  

    

url = os.environ['SITEURL']

excludetags = os.environ['EXCLUDETAGS']
if excludetags == "":
  excludetags = "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"

includetags = os.environ['INCLUDETAGS']
if includetags == "":
  includetags = "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"

excludetitles = os.environ['EXCLUDETITLES']
if excludetitles == "":
  excludetitles = "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
  
includetitles = os.environ['INCLUDETITLES']
if includetitles == "":
  includetitles = "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
  
if os.environ.get('INCLUDEPOSTTAGS'):
  includetags = os.environ['INCLUDEPOSTTAGS'] # comma separated
  includetagslist = includetags.split(",")

if os.environ.get('EXCLUDEPOSTTAGS'):
  excludeposttagslist = os.environ['EXCLUDEPOSTTAGS'] # regrex
  
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)


rssdir='/home/'+getpass.getuser()+'/public_html/'+'RSSs'  ############# XML folder
sitetype = re.sub(r'_$', r'', re.sub(r'(/|\?|=|&)', r'_', re.sub(r'^www\.', r'', re.sub(r'^http(|s).{3}', r'', url))))

print(sitetype+' RSS')
lastarticlesfile=rssdir+'/'+sitetype+'_lastarticles.txt'
rssxml=rssdir+'/'+sitetype+'_revisited_rss.xml'

# # display = Display(visible=0, size=(800, 600))
# # display.start()
# # driver = webdriver.Firefox() # create a firefox profile before this!
# # driver.get(url)
# # # try:
# # #     element = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.NAME, "tags")))
# # # finally:
# # #     driver.quit()
# # soup = BeautifulSoup(driver.page_source , 'html.parser')

# # # r = Render(url)  
# # # html = r.frame.toPlainText()
# # # webpage = str(r.toUtf8()).decode("utf-8")
reconnect=True
while reconnect:
  try:
    reconnect=False
    urldata = urllib2.urlopen(url, timeout = 120)
  except urllib2.URLError, e:
    time.sleep(5)
    reconnect=True
webpage = urldata.read()
urldata.close()
webpage=re.sub(r"NNNNNN", r'\n', re.sub(r'^.*(<\?xml.*>)', r'\1', re.sub(r'\n', 'NNNNNN', webpage)))
soup = BeautifulSoup(webpage, 'html.parser')
rsslinkx1='nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn'
rsslinkx2='nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn'
if soup.find(attrs={'type':'application/rss+xml'}):
  rsslinkx1=soup.find(attrs={'type':'application/rss+xml'})['href']
  if ( isinstance(soup.find_all(attrs={'type':'application/rss+xml'}), list) and ( len(soup.find_all(attrs={'type':'application/rss+xml'})) > 1 ) ):
    rsslinkx2=soup.find_all(attrs={'type':'application/rss+xml'})[1]['href']
elif soup.find(attrs={'type':'application/atom+xml'}):
  rsslinkx1=soup.find(attrs={'type':'application/atom+xml'})['href']
  if ( isinstance(soup.find_all(attrs={'type':'application/atom+xml'}), list) and ( len(soup.find_all(attrs={'type':'application/atom+xml'})) > 1 ) ):
    rsslinkx2=soup.find_all(attrs={'type':'application/atom+xml'})[1]['href']
rsslinkx1=re.sub('&', 'Xampx', re.sub('\?', 'X',rsslinkx1))
rsslinkx2=re.sub('&', 'Xampx', re.sub('\?', 'X',rsslinkx2))
rsslinknew='http://nestukh.uni.cx:8099'

touch(lastarticlesfile)
rootdoc = ET.fromstring(webpage)
if os.path.exists(rssxml):
  os.remove(rssxml)
  open(rssxml, 'a').close()
    

preroot = re.sub(r"NNNNNN", r'\n', re.sub(r"<rss.*", r'', re.sub(r"\n", r'NNNNNN', webpage)))
rootonly = re.sub(r"NNNNNN", r'\n', re.sub(r'<link>.*<\/link>', '<link>'+rsslinknew+'</link>', re.sub(r'<title>(.*)<\/title>', r'<title>\1 Revisited</title>', re.sub(rsslinkx2, rsslinknew, re.sub(rsslinkx1, rsslinknew, re.sub('&amp;', 'Xampx', re.sub('\?', 'X', re.sub(r"<item.*item>", r'<!-- done by rssfilter.sh -->', re.sub(r"\n", r'NNNNNN', ET.tostring(rootdoc))))))))))
postroot = re.sub(r"NNNNNN", r'\n', re.sub(r".*/rss>", r'', re.sub(r"\n", r'NNNNNN', webpage)))
rssxml2write = open(rssxml, 'w')
rssxml2write.write(preroot+'\n'+rootonly+'\n'+postroot)
rssxml2write.close()

items = soup.find_all('item')
titles = [string.find('title') for string in soup.find_all('item')]
links = [string.find('link') for string in soup.find_all('item')]
categories = [string.find_all('category') for string in soup.find_all('item')]

databasearticle2read = open(lastarticlesfile, 'r')
databasearticlelines = databasearticle2read.readlines()
databasearticle2read.close()
databasearticle2write = open(lastarticlesfile, 'a')
rssxml2read = open(rssxml, 'r')
rssxmllines = rssxml2read.readlines()
rssxml2read.close()

insertitemhere = re.compile(".*<!-- done by rssfilter.sh -->")
for j, (line) in enumerate(rssxmllines):
  if insertitemhere.match(line):
    itemlineindex=j+1
    break

for j, (t,l,cats,item) in enumerate(zip(titles,links,categories,items)):
  articleincluded=''
  if any(re.search(l.text, x) for x in databasearticlelines):
    continue
  itemok=False
  titleok=False
  itemposttagsok=False
  if not (excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
    if not re.search(excludetitles, t.text):
      itemok=True
  if not (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
    if re.search(includetitles, t.text):
      itemok=True
  if ((excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn") and (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn")):
    titleok=True
  if itemok or titleok:
    if ( len(cats) > 0 ):
      for c in cats:
        if not (excludetags == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
          if re.search(excludetags, c.text):
            itemok=False
      if not (includetags == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
        for c in cats:
          if re.search(includetags, c.text):
            itemok=True
  if (os.environ.get('INCLUDEPOSTTAGS') or os.environ.get('EXCLUDEPOSTTAGS')):
    reconnect=True
    while reconnect:
      try:
        reconnect=False
        metawebchunk = urllib2.urlopen(l.text, timeout = 120).read(20000) # read first 20000 bits of this page
      except IOError as (errno, strerror):
        print "I/O error({0}): {1}".format(errno, strerror)
      except ValueError:
        print "Could not convert data to an integer."
      except:
        time.sleep(5)
        reconnect=True
    if 'nuovavenezia' in url:
      metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'</head>.*', r'</head><body></body></html>', re.sub(r'\n', r"NNNNNN", metawebchunk)))
      postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
      if postsoup.find("meta",{"name":"tags"}):
        tags=postsoup.find("meta",{"name":"tags"})['content']
        tags=re.sub(r",$", r'', tags)
        taglist = tags.split(",")
        for tagx in includetagslist:
          if any(tagx in s for s in taglist):
            itemposttagsok=True
            break
      else:
        itemposttagsok=True
      description=postsoup.find("meta",{"name":"description"})['content']
      if not (excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
        if not re.search(excludetitles, description):
          itemok=True
      if not (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
        if re.search(includetitles, description):
          itemok=True
      if ((excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn") and (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn")):
        titleok=True
    if 'Makeuseof' in url:
      metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'<body>.*<body', r'<body', re.sub(r'^.*</head>(.*)', r'<\!DOCTYPE html>\n<html lang="en" xmlns:fb="http://ogp.me/ns/fb#">\n<head></head>\1</body></html>', re.sub(r'\n', r"NNNNNN", metawebchunk))))
      postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
      catego=re.sub(r'^.*makeuseof.com/service/(.*)/', r'\1', postsoup.find("div",{"class":"category"}).find('a')['href'])
      if not re.search(excludeposttagslist, catego):
        itemposttagsok=True
  else:
    itemposttagsok=True
  if (itemok and itemposttagsok):
    print(unicodedata.normalize('NFKD', t.text).encode('ascii','ignore'))
    itemx=str(item)+'\n'
    rssxmllines.insert(itemlineindex, itemx)
    articleincluded=' --> INCLUDED IN RSS FEED'
  databasearticle2write.write(str(l)+articleincluded+'\n')
  
databasearticle2write.close()
rssxmllines = "".join(rssxmllines)
rssxml2write = open(rssxml, 'w')
rssxml2write.write(rssxmllines)
rssxml2write.close()

END
}










# wget -q -O-  http://feed/ # (xml file) # tags are "<category>"
# these are regrex rules
# '!' for not escaping it in bash
# "^(?!.*(pattern1|pattern2)).*$" = not(pattern1|pattern2) in python---> use $(echo -e "\041") for ! in bash variable # does not work
# "^((?!.*(pattern2include1|pattern2include2)).*)|(pattern2exclude1|pattern2exclude2)$" # does not work
#  "((^(?$(echo -e "\041").*(pattern2include1|pattern2include2)).*$)|(pattern2exclude1|pattern2exclude2))" # does not work


declare -a rssfeeds=(ilpost LegaNerd lifehacker technologyreview Makeuseof attivissimo fromquarkstoquasars hackaday nuovavenezia) # italians
for r in "${rssfeeds[@]}"; do
  unset rssfeed
  unset tagexclude
  unset taginclude
  unset titleexclude
  unset titleinclude
  unset posttagsinclude
  unset posttagsexclude

  case "$r" in
    ilpost)
      rssfeed='http://www.ilpost.it/feed/'
      tagexclude="(post-it|Sport|Video|[Pp]olitica|[Mm]oda|[Ff]oto del giorno|virgolette)"
      taginclude=""
      titleexclude="(Le migliori foto di oggi|Celebripost|calcio|Come vedere|Peanuts|Doonesbury|prime pagine di oggi|foto pi. belle di oggi|foto d(i|el|ei)|[Bb]ombarda|in streaming|Serie A|[Aa]llaga|nuovo singolo|ha \d+ anni|strage|[Rr]ifugiati]|autopsia|Le ultime su|copertina d(i|el|ei)|attentato|[Ss]tupr|[Ii]ncendio|nuovo disco|[Aa]ccoltell|fatto causa|(È|è) mort[oa]|uragano|tifone|si vota in|canzoni d(i|ella|ei|elle)|elezioni|Star Wars|ha(|nno) vinto (la destra|la sinistra|i liberali|i conservatori)|processo per|incontro (tra|fra)|poster )"
      titleinclude="(, spiegat[oa]|[Sc]acchi)"
      ;;
    LegaNerd)
      rssfeed='http://feeds.feedburner.com/LegaNerd'
      tagexclude="(NSFW|trailer|promo|teaser|tv series)"
      taginclude=""
      titleexclude="(NSFW|Cosplay|Spot|Netflix|Comic.Con|[Tt]railer|Marvel|Promo|Cosplayer|StarWars|Star.Wars|\d+ Bit)"
      titleinclude=""
      ;;
    lifehacker)
      rssfeed='http://feeds.gawker.com/lifehacker/full'
      tagexclude="(apple|deals)"
      taginclude=""
      titleexclude="(\[Deals\]|This Week.s|Deals:|Open Thread|Ask .n .xpert|[Dd]iscounts|Lifehacker.*Meetup)"
      titleinclude=""
      ;;
    technologyreview)
      rssfeed='http://www.technologyreview.com/stream/rss/'
      tagexclude=""
      titleexclude="(\(Week Ending|Recommended.*Read|Other Interesting arXiv Papers|Must-Read Stories|Recommended from Around the Web)"
      titleinclude=""
      ;;
    Makeuseof)
      rssfeed='http://feeds2.feedburner.com/Makeuseof'
      tagexclude="(Deals|Discount|Social Media|Tech News|costumes|Sponsored|Announcements)"
      taginclude="(Android|[Ll]inux|Self Improvement|management|Technology Explained|star trek|[Pp]rogramming|[Ss]ecurity|[Rr]asp)"
      titleexclude="(MakeUseOf Poll|Tech News Digest|[Gg]iftcard|Football|Selfie|Deals|Review and Giveaway|Microsoft Office|Mac Users|El Capitan|Windows 10|Facebook)"
      titleinclude="(Android|[Ll]inux|[Ee]book|Self Improvement|management|Technology Explained|star trek|[Pp]rogramming|[Ss]ecurity|[Rr]asp)"
      posttagsinclude=""
      posttagsexclude="(windows|ios|news)"
      ;;
    attivissimo)
      rssfeed='http://attivissimo.blogspot.com/feeds/posts/full?alt=rss'
      tagexclude=""
      taginclude=""
      titleexclude="(Podcast|Ci vediamo|Facebook|Astrosamantha|[Ss]tasera|parliamo|Hangout|iOS|OS X)"
      titleinclude=""
      ;;
    fromquarkstoquasars)
      rssfeed='http://www.fromquarkstoquasars.com/feed/'
      tagexclude=""
      taginclude=""
      titleexclude="(Astronomy Photo of the Day)"
      titleinclude=""
      ;;
    hackaday)
      rssfeed='http://hackaday.com/feed/'
      tagexclude="(cons)"
      taginclude=""
      titleexclude="(Fail of the Week|Macintosh|Retro|Links:|[Gg]am[ei]|PowerMac|Arcade)"
      titleinclude=""
      ;;
#     italians)
#       rssfeed='http://italians.corriere.it/feed/'
#       tagexclude=""
#       titleexclude="(Fail of the Week|Macintosh|Retro|Links:|[Gg]am[ei]|PowerMac|Arcade)"
#       ;;
    nuovavenezia)
      rssfeed='http://nuovavenezia.gelocal.it/rss/cmlink/rss-nuova-venezia-venezia-cronaca-1.10334773'
      tagexclude=""
      taginclude=""
      titleexclude=""
      titleinclude="([Mm]oto.[Oo]ndoso|mail|[Gg]ondol|boat|[Mm]ose|[Dd]vd|(^| )[Vv]oga|[Rr]egat|[Ll]aguna|Oriago|(^| )[Cc]avan|[Cc]atamaran|(^| )[Vv]el[aei]|[Ll]ancion| porto|diporto|Mira|Oriago|Unesco|Biennale|(^| )[Mm]ar[ei]|[Rr]emier|Fresco|(^| )[Bb]ate|[Pp]upparin|[Cc]aorlin|Canal.Grande|(^| )[Rr]em|Naviglio|(^| )[Bb]arc|Vogalonga|(^| )[Vv]ar[ao]|[Aa]cqua.alta|(^| )[Aa]cqu[ae]|(^| )[Nn]av[ei]|[Yy]acht|[Mm]otoscaf|(^| )[Rr]io|[Ii]dro|(^| )[Rr]ii|[Cc]anal|Argos|[Ss]cioper|Redentore|Riviera|[Pp]onte|[Mm]aratona|Marathon|(^| )[Aa]lg[ah]|(^| )[Ii]sol[ae])"
      posttagsinclude="grandi navi,mose,moto ondoso,no grandi navi,regatastorica,voga"
      ;;
  esac

  RSSFiltering "$rssfeed" "$tagexclude" "$taginclude" "$titleexclude" "$titleinclude" "$posttagsinclude" "$posttagsexclude"
  echo;
  
done






# http://nestukh.uni.cx:8099/~server/RSSs/attivissimo.blogspot.com_feeds_posts_full_alt_rss_revisited_rss.xml
# http://nestukh.uni.cx:8099/~server/RSSs/feeds2.feedburner.com_Makeuseof_revisited_rss.xml
# http://nestukh.uni.cx:8099/~server/RSSs/feeds.feedburner.com_LegaNerd_revisited_rss.xml
# http://nestukh.uni.cx:8099/~server/RSSs/feeds.gawker.com_lifehacker_full_revisited_rss.xml
# http://nestukh.uni.cx:8099/~server/RSSs/fromquarkstoquasars.com_feed_revisited_rss.xml
# http://nestukh.uni.cx:8099/~server/RSSs/ilpost.it_feed_revisited_rss.xml
# http://nestukh.uni.cx:8099/~server/RSSs/technologyreview.com_stream_rss_revisited_rss.xml
# http://nestukh.uni.cx:8099/~server/RSSs/hackaday.com_feed_revisited_rss.xml
# http://nestukh.uni.cx:8099/~server/RSSs/nuovavenezia.gelocal.it_rss_cmlink_rss-nuova-venezia-venezia-cronaca-1.10334773_revisited_rss.xml

exit 0


