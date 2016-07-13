#!/bin/bash


# user here is 'server'

# check with
# crontab -e
# 1  *    *   *  *    bash /home/server/Scripts/rssfilter.sh




### installing requirements (more than necessary)
# sudo apt-get install ca-certificates expect youtube-dl python-qt4 xvfb pcregrep python3-dev libqt4-dev python-pip python-qt4-dev build-essential python-lxml; sudo pip install --upgrade regex beautifulsoup4 requests youtube_dl python3 python3-doc python3-tk python3-examples tix python-bluez python-gobject python-dbus python cython python-doc python-tk python-examples python-numpy python-scipy python-vte python-qt4 python-lxml python-setuptools fontconfig python-demjson #### selenium pyvirtualdisplay feedgenerator  feedparser
# sudo easy_install pip
# sudo pip install --upgrade pip
# sudo easy_install -U setuptools
# sudo pip install --upgrade regex requests beautifulsoup4 xvfbwrapper selenium pyvirtualdisplay feedgenerator youtube_dl

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

# sudo mv /bin/sh /bin/sh.orig
# sudo ln -s /bin/bash /bin/sh


# open port 8099 on your router for your server at port 80, then use a dyndns

# http://nestukh.uni.cx:8099/~server/RSSs/FEEDSITE_rss.xml



# be sure that cron is running using 'ps -ef | grep cron'
# if not, insert '/etc/init.d/cron start' in /etc/rc.local (Raspian distro)


export PATH=$PATH:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/bin:/usr/local/games:/usr/games:$HOME/Scripts:$HOME/Scripts/Dropbox-Uploader: # not included in crontab env
source $HOME/.bashrc


















































function RSSFiltering {
SITEURL="$1" EXCLUDETAGS="$2" INCLUDETAGS="$3" EXCLUDETITLES="$4" INCLUDETITLES="$5" INCLUDEPOSTTAGS="$6" EXCLUDEPOSTTAGS="$7" EXCLUDELINKS="$8" INCLUDELINKS="$9" MULTIPLEFEED="${10}" xvfb-run -a python - <<END
#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import linecache
import time
import codecs
from bs4 import BeautifulSoup
# # # from PyQt4.QtGui import *  
# # # from PyQt4.QtCore import *  
# # # from PyQt4.QtWebKit import *
import urllib2
import math
import re
import json
from pprint import pprint
import unicodedata
import getpass
import six
import copy
import requests
import ssl
import string
import datetime
import sqlite3 as dbapi
# # # import lxml.etree as LET
from xml.etree import ElementTree as ET
from xml.dom import minidom
# # # import io
# # from selenium import webdriver
# # from selenium.webdriver.common.by import By
# # from selenium.webdriver.support.ui import WebDriverWait
# # from selenium.webdriver.support import expected_conditions as EC
# # from pyvirtualdisplay import Display

hdr = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
       'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
       'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
       'Accept-Encoding': 'none',
       'Accept-Language': 'en-US,en;q=0.8',
       'Connection': 'keep-alive'}
       
gcontext = ssl.SSLContext(ssl.PROTOCOL_TLSv1) 





def detouch(fname):
  if not os.path.exists(fname):
    open(fname, 'a').close()
  if ((os.path.exists(fname)) and (os.path.getsize(fname) > 900000)):  # bytes, more than 900KB
    # #os.remove(fname)
    # #open(fname, 'a').close()
    data = open(fname, 'r').read().splitlines(True)
    open(fname, 'w').writelines(data[-30:])  # last 30 links
    fname.close()

def tounicodestr(s):
  if isinstance(s, str):
    return s.decode('utf8')
  elif isinstance(s, unicode):
    return s
  else:
    return s
    
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


def printa(stringa):
  printable = set(string.printable)
  print filter(lambda x: x in printable, stringa)
  
def PrintException():
  exc_type, exc_obj, tb = sys.exc_info()
  f = tb.tb_frame
  lineno = tb.tb_lineno
  filename = f.f_code.co_filename
  linecache.checkcache(filename)
  line = linecache.getline(filename, lineno, f.f_globals)
  errorlogx=str('EXCEPTION IN ({}, LINE {} "{}"): {}'.format(filename, lineno, line.strip(), exc_obj))
  return errorlogx



def main():
  try:  
    url = os.environ['SITEURL']

    excludetags = os.environ['EXCLUDETAGS']
    if excludetags == "":
      excludetags = "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"

    includetags = os.environ['INCLUDETAGS']
    if includetags == "":
      includetags = "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"

    excludetitles = os.environ['EXCLUDETITLES'].decode('utf8')
    if excludetitles == "":
      excludetitles = "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
      
    includetitles = os.environ['INCLUDETITLES'].decode('utf8')
    if includetitles == "":
      includetitles = "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
      
    if os.environ.get('INCLUDEPOSTTAGS'):
      includeposttagslist = os.environ['INCLUDEPOSTTAGS'] # regrex

    if os.environ.get('EXCLUDEPOSTTAGS'):
      excludeposttagslist = os.environ['EXCLUDEPOSTTAGS'] # regrex
      
      
    if os.environ.get('INCLUDELINKS'):
      includelinkslist = os.environ['INCLUDELINKS'] # regrex

    if os.environ.get('EXCLUDELINKS'):
      excludelinkslist = os.environ['EXCLUDELINKS'] # regrex

    ismultifeed = False
    if os.environ.get('MULTIPLEFEED'):
      ismultifeed = True
      urls=url.split(" ")
      url=urls[0]
      otherurls=urls[1:]
      webpages=[]
      soups=[]
      
      
      ###################################################
      
    UTF8Writer = codecs.getwriter('utf8')
    sys.stdout = UTF8Writer(sys.stdout)


    rssdir='/home/'+getpass.getuser()+'/public_html/'+'RSSs'  ############# XML folder
    sitetype = re.sub(r'_$', r'', re.sub(r'(/|\?|=|&)', r'_', re.sub(r'^www\.', r'', re.sub(r'^http(|s).{3}', r'', url))))

    print(sitetype+' RSS')
    lastarticlesfile=rssdir+'/'+sitetype+'_lastarticles.txt'
    rssxmlfile=sitetype+'_revisited_rss.xml'
    rssxml=rssdir+'/'+rssxmlfile
    pubsubhubbub_Hub_Server = 'http://nestukh.superfeedr.com/' ############# totally free, but: no reject subscribers, no fat ping, no custom hub second level domain
    self_Hub_Server = 'http://nestukh.uni.cx:8099/~server/RSSs/'
    rssxmlurl=self_Hub_Server+rssxmlfile
    rsslinknew='http://nestukh.uni.cx:8099'




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
    

    try:
      urllib2.urlopen("http://google.com", context=gcontext, timeout = 240)
      try:
        conn = urllib2.urlopen(url, context=gcontext, timeout = 60).getcode()
        if str(conn).startswith('5'): ## check if we get a server error 5xx
          errmessage= url+ ' --- OFFLINE: http error '+ str(conn)+'\n'
          print errmessage
          sys.exit()
        elif '408' in str(conn): ## timed out
          errmessage= url+ ' --- TIMED OUT: http error '+ str(conn)+'\n'
          print errmessage
          sys.exit()
        elif '104' in str(conn): ## Connection reset by peer
          errmessage= url+ ' --- CONNECTION RESET BY PEER: http error '+ str(conn)+'\n'
          print errmessage
          sys.exit()
        else:
          pass
      except urllib2.URLError, e:
        errmessage= url + ' --- OFFLINE: '+str(e)+ '\n' + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + '\n'
        print errmessage
        sys.exit()
      except Exception, e:
        errmessage= url + ' --- PROBLEMATIC: '+str(e)+ '\n' + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + '\n'
        print errmessage
        sys.exit()
    except urllib2.URLError:
      errmessage='there is no internet connection:' + '\n' + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + '\n'
      print errmessage
      sys.exit()
    
    

    reconnect=True
    wcount=0
    while reconnect and wcount < 10:
      try:
        reconnect=False
        wcount = wcount + 1
        webpagechunk = urllib2.urlopen(url, context=gcontext, timeout = 60).read(4400)
      except IOError:
        time.sleep(5)
        reconnect=True
      except ValueError:
        time.sleep(5)
        reconnect=True
    #   except urllib2.URLError, e:
    #     time.sleep(5)
    #     reconnect=True
      except:
        time.sleep(5)
        reconnect=True
    if wcount >= 10:
      raise Exception('infinite loop')
    originalurl=url
    if not re.search('version=.(2.0|0.91).', webpagechunk):
      url = 'http://www.devtacular.com/utilities/atomtorss/?url=' + url  # atom to rss feed converter

    if ismultifeed:
      originalotherurls=otherurls[0:]
      for j, (uu) in enumerate(zip(otherurls)):
        reconnect=True
        wcount=0
        while reconnect and wcount < 10:
          try:
            reconnect=False
            wcount = wcount + 1
            wpc=urllib2.urlopen(uu[0], context=gcontext, timeout = 60).read(4400)
          except IOError:
            time.sleep(5)
            reconnect=True
          except ValueError:
            time.sleep(5)
            reconnect=True
          #   except urllib2.URLError, e:
          #     time.sleep(5)
          #     reconnect=True
          except:
            time.sleep(5)
            reconnect=True
        if wcount >= 10:
          raise Exception('infinite loop')
        if not re.search('version=.(2.0|0.91).', wpc):
          otherurls[j] = 'http://www.devtacular.com/utilities/atomtorss/?url=' + uu[0]  # atom to rss feed converter
      

      
      
    reconnect=True
    wcount=0
    while reconnect and wcount < 10:
      try:
        reconnect=False
        wcount = wcount + 1
        webpage = urllib2.urlopen(url, context=gcontext, timeout = 60).read()
      except IOError:
        print 'IOError'
        time.sleep(5)
        reconnect=True
      except ValueError:
        print 'ValueError'
        time.sleep(5)
        reconnect=True
      except:
        print 'error'
        time.sleep(5)
        reconnect=True
    if wcount >= 10:
      raise Exception('infinite loop')
    if 'An error occurred while transforming the Atom 1.0 Feed to RSS 2.0.' in webpage: # A
      errmessage= url+ ' --- BAD FORMATTING: An error occurred while transforming the Atom 1.0 Feed to RSS 2.0. Please follow the instructions presented and ensure that you have sufficiently encoded your feed URL for processing.'+'\n'
      print errmessage
      sys.exit()
    webpagetemp1 = re.sub(r'\n', 'NNNNNN', re.sub(' encoding=\"utf-16\"', ' encoding=\"UTF-8\"', webpage))
    if len(webpagetemp1.split("<?xml")) > 1:
      webpagetemp2=re.sub(r'^'+webpagetemp1.split("<?xml")[0]+re.escape('<?xml'), '<?xml', webpagetemp1, 1)
    else:
      webpagetemp2=webpagetemp1
    webpage = re.sub(r"NNNNNN", r'\n', webpagetemp2)
    
    if ismultifeed:
      for j, (uu) in enumerate(zip(otherurls)):
        reconnect=True
        wcount=0
        while reconnect and wcount < 10:
          try:
            reconnect=False
            wcount = wcount + 1
            wp=urllib2.urlopen(uu[0], context=gcontext, timeout = 60).read()
          except IOError:
            time.sleep(5)
            reconnect=True
          except ValueError:
            time.sleep(5)
            reconnect=True
          except:
            time.sleep(5)
            reconnect=True
        if wcount >= 10:
          raise Exception('infinite loop')
        if 'An error occurred while transforming the Atom 1.0 Feed to RSS 2.0.' in wp: # A
          errmessage= url+ ' --- BAD FORMATTING: An error occurred while transforming the Atom 1.0 Feed to RSS 2.0. Please follow the instructions presented and ensure that you have sufficiently encoded your feed URL for processing.'+'\n'
          print errmessage
          sys.exit()
        webpagetemp = re.sub(r'\n', 'NNNNNN', re.sub(' encoding="utf-16"', ' encoding="UTF-8"', wp))
        webpages.append(re.sub(r"NNNNNN", r'\n', re.sub(r'^'+webpagetemp.split("<?xml")[0]+re.escape('<?xml'), '<?xml', webpagetemp, 1)))
        

    
    
    
    
    
    

    soup = BeautifulSoup(webpage, 'html.parser')
    if ismultifeed:
      for j, (uu) in enumerate(zip(otherurls)):
        soups.append(BeautifulSoup(webpages[j], 'html.parser'))

    
    
    
    

    detouch(lastarticlesfile)
    rootdoc = ET.fromstring(webpage)

    if os.path.exists(rssxml):
      os.remove(rssxml)
      open(rssxml, 'a').close()
        

    preroot = re.sub(r"NNNNNN", r'\n', re.sub(r"<rss.*", r'', re.sub(r"\n", r'NNNNNN', webpage)))

    # rootonly = re.sub(r"NNNNNN", r'\n', re.sub(r'<link>([^<>]+)<\/link>', '<link>'+rsslinknew+'</link>', re.sub(r'<title>([^<>]+)<\/title>', r'<title>\1 Revisited</title>', re.sub(rsslinkx2, rsslinknew, re.sub(rsslinkx1, rsslinknew, re.sub('&amp;', 'Xampx', re.sub('\?', 'X', re.sub(r"<item.*item>", r'NNNNNN<!-- done by rssfilter.sh -->NNNNNN', re.sub(r"\n", r'NNNNNN', ET.tostring(rootdoc))))))))))
    rootonly = re.sub(r"NNNNNN", r'\n', 
      re.sub(r'Revisited</title>', r'Revisited</title>NNNNNN<link>'+rsslinknew+'</link>NNNNNN<!-- PubSubHubbub Discovery -->NNNNNN<link rel=\"hub\"  href=\"'+pubsubhubbub_Hub_Server+'\" xmlns=\"http://www.w3.org/2005/Atom\" />NNNNNN<link rel=\"self\" href=\"'+rssxmlurl+'\" type=\"application/rss+xml\" xmlns=\"http://www.w3.org/2005/Atom\" />NNNNNN<!-- End Of PubSubHubbub Discovery -->NNNNNN', 
      re.sub(r'<title>([^<>]+)<\/title>', r'<title>\1 Revisited</title>', 
      re.sub(r'<([^<>]+):link([^<>]+)<\/([^<>]+):link>', r'', 
      re.sub(r'<([^<>]+):link([^<>]+)\/>', r'', 
      re.sub(r'<link>([^<>]+)\/>', r'', 
      re.sub(r'<link>([^<>]+)<\/link>', r'', 
      re.sub(r'<image>.*<\/image>', r'', 
      re.sub(r"<item.*item>", r'NNNNNN<!-- done by rssfilter.sh -->NNNNNN', 
      re.sub(r"\n", r'NNNNNN', ET.tostring(rootdoc)))))))))))
    postroot = re.sub(r"NNNNNN", r'\n', re.sub(r".*/rss>", r'', re.sub(r"\n", r'NNNNNN', webpage)))
    rssxml2write = open(rssxml, 'w')
    rssxml2write.write(preroot+'\n'+rootonly+'\n'+postroot)
    rssxml2write.close()

    items = soup.find_all('item')        
    titles = [string.find('title') for string in items]
    if re.search('feedburner:origlink', webpage):
      linkstext = [re.sub(r'$', '</link>', re.sub(r'^', '<link>', string.find('feedburner:origlink').text)) for string in items]
      linksweb = ''.join(linkstext)
      linkssoup = BeautifulSoup(linksweb, 'html.parser')
      links = [string for string in linkssoup.find_all('link')]
    else:
      links = [string.find('link') for string in items]
    if ismultifeed:
      for j, (uu) in enumerate(zip(otherurls)):
        otheritems=soups[j].find_all('item')
        othertitles = [string.find('title') for string in otheritems]
        if re.search('feedburner:origlink', webpages[j]):
          linkstext = [re.sub(r'$', '</link>', re.sub(r'^', '<link>', string.find('feedburner:origlink').text)) for string in otheritems]
          linksweb = ''.join(linkstext)
          linkssoup = BeautifulSoup(linksweb, 'html.parser')
          otherlinks = [string for string in linkssoup.find_all('link')]
        else:
          otherlinks = [string.find('link') for string in otheritems]
        for k, (ol,ot,oi) in enumerate(zip(otherlinks,othertitles,otheritems)):
          if any(re.search(re.escape(re.sub(r'\?', '.', re.sub(r'\?utm_source=.*$', '', re.sub('\?rss', '', re.sub(r'\/?rss\]\]>$', r'', re.sub(r'^<!\[CDATA\[', r'', re.sub(r'http(|s)://[a-z.0-9_]+', r'', ol.text))))))), x.text) for x in links):
            continue
          links.append(ol)
          items.append(oi)
          titles.append(ot)

    if ('Disinformatico' in originalurl):
      reconnect=True
      wcount=0
      while reconnect and wcount < 10:
        try:
          reconnect=False
          wcount = wcount + 1
          originalwebpage = urllib2.urlopen(originalurl, context=gcontext, timeout = 60).read()
        except IOError:
          time.sleep(5)
          reconnect=True
        except ValueError:
          time.sleep(5)
          reconnect=True
        except:
          time.sleep(5)
          reconnect=True
      if wcount >= 10:
        raise Exception('infinite loop')
      originalsoup = BeautifulSoup(originalwebpage, 'html.parser')
      linkstext = [re.sub(r'$', '</link>', re.sub(r'^', '<link>', string.find('feedburner:origlink').text)) for string in originalsoup.find_all('entry')]
      linksweb = ''.join(linkstext)
      linkssoup = BeautifulSoup(linksweb, 'html.parser')
      links = [string for string in linkssoup.find_all('link')]
    if ('lxer' in url):
      reconnect=True
      wcount=0
      while reconnect and wcount < 10:
        try:
          reconnect=False
          wcount = wcount + 1
          webpage = urllib2.urlopen('http://lxer.com/module/newswire/headlines.rss', context=gcontext, timeout = 60).geturl()
        except IOError:
          time.sleep(5)
          reconnect=True
        except ValueError:
          time.sleep(5)
          reconnect=True
        except:
          time.sleep(5)
          reconnect=True
      if wcount >= 10:
        raise Exception('infinite loop')
      soup = BeautifulSoup(webpage, 'html.parser')
      redirlinks = copy.deepcopy(links)
      links = [string.find('link') for string in soup.find_all('item')]
    if ('news.ycombinator' in url):
      minscore = 260
      originallinks=links[0:]
      linkstext = [re.sub(r'$', '</link>', re.sub(r'^', '<link>', str(re.sub(r'\".*$', '', re.sub(r'^<a href=\"', '', string.find('description').string))))) for string in items]
      linksweb = ''.join(linkstext)
      linkssoup = BeautifulSoup(linksweb, 'html.parser')
      links = [string for string in linkssoup.find_all('link')]
      
      
      
    for j, (t,l) in enumerate(zip(titles,links)):  # doppio zip senno' ritorna l come una tuplal.text
      if ('feedproxy.google.com' in l.text):
        reconnect=True
        wcount=0
        while reconnect and wcount < 10:
          try:
            reconnect=False
            wcount = wcount + 1
            a=urllib2.urlopen(urllib2.Request(l.text, headers=hdr), context=gcontext, timeout = 60).geturl()
          except urllib2.HTTPError, e:
            if e.getcode() == 403:
              a=e.geturl()
              reconnect=False
            else:
              a=l.text
              reconnect=False
          except IOError:
            time.sleep(5)
            reconnect=True
          except ValueError:
            time.sleep(5)
            reconnect=True
          except:
            time.sleep(5)
            reconnect=True
        if wcount >= 10:
          raise Exception('infinite loop')
        links[j].string = a


    categories = [string.find_all('category') for string in items]
    if not len(categories) == len(links):
      categories= [None] * len(links)
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

    newscount=0
    for j, (t,l,cats,item) in enumerate(zip(titles,links,categories,items)):
      articleincluded=''
      if any(re.search(re.escape(re.sub(r'\?', '.', re.sub(r'\?utm_source=.*$', '', re.sub('\?rss', '', re.sub(r'\/?rss\]\]>$', r'', re.sub(r'^<!\[CDATA\[', r'', l.text)))))), x) for x in databasearticlelines):
        continue
      itemok=False
      itemposttagsok=False
      #titlestring = unicodedata.normalize('NFKD', t.text).encode('ascii','ignore')
      if not (excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
        if not re.search(ur'{0}'.format(excludetitles), tounicodestr(t.text), flags=re.IGNORECASE|re.UNICODE):
          itemok=True
      if not (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
        if re.search(ur'{0}'.format(includetitles), tounicodestr(t.text), flags=re.IGNORECASE|re.UNICODE):
          itemok=True
      if ((excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn") and (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn")):
        itemok=True
      if itemok:
        if ( len(cats) > 0 ):
          if not (excludetags == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
            for c in cats:
              if re.search(excludetags, c.text, flags=re.IGNORECASE):
                itemok=False
          if not (includetags == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
            for c in cats:
              if re.search(includetags, c.text, flags=re.IGNORECASE):
                itemok=True
      if (os.environ.get('INCLUDEPOSTTAGS') or os.environ.get('EXCLUDEPOSTTAGS')):
        if 'news.ycombinator' in url:
          itemok=True
          if not (excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
            if re.search(ur'{0}'.format(excludetitles), tounicodestr(t.text), flags=re.IGNORECASE|re.UNICODE):
              itemok=False
          if not (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
            if re.search(ur'{0}'.format(includetitles), tounicodestr(t.text), flags=re.IGNORECASE|re.UNICODE):
              itemok=True
          if ((excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn") and (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn")):
            itemok=True
          if itemok:
            itemposttagsok=True
            linka=l.text
            qq=re.sub(r'http(|s)://', '', re.sub(re.sub(r'http(|s)://[a-z.0-9_]+', r'', originallinks[j].text), '', originallinks[j].text))
            if os.environ.get('EXCLUDEPOSTTAGS'):
              if re.search(excludeposttagslist, qq,flags=re.IGNORECASE):
                itemposttagsok=False
            if os.environ.get('INCLUDEPOSTTAGS'):
              if re.search(includeposttagslist, qq,flags=re.IGNORECASE):
                itemposttagsok=True
            if itemposttagsok:
              hackernewslinksfile=rssdir+'/'+'_hackernewslinks.sql'
              if not os.path.exists(hackernewslinksfile):
                createDB=True
              else:
                createDB=False
              hackernewsDB = dbapi.connect(hackernewslinksfile)
              c = hackernewsDB.cursor()
              if createDB:
                c.execute("""create table hackernews (hnlink text COLLATE NOCASE, hntitle text COLLATE NOCASE, hnitem text COLLATE NOCASE, hnisincurrentnews int)""")  # hnisincurrentnews 0 or 1
              c.execute("""SELECT * FROM hackernews WHERE hnlink LIKE '%{my_str}%' COLLATE NOCASE""".format(my_str=re.sub(r'\'', '\'\'',linka)))
              id_exists = c.fetchone();
              isincurrentnews=1
              if id_exists:
                c.execute("""UPDATE hackernews SET hnisincurrentnews = replace(hnisincurrentnews, '0', '1') where hnlink=?""", (linka,))
                hackernewsDB.commit()
              linkapi=re.sub('$', '.json?print=pretty', re.sub(re.escape('https://news.ycombinator.com/item?id='), 'https://hacker-news.firebaseio.com/v0/item/', linka)) # https://github.com/HackerNews/API
              reconnect=True
              wcount=0
              while reconnect and wcount < 10:
                try:
                  reconnect=False
                  wcount = wcount + 1
                  metawebchunk = urllib2.urlopen(re.sub('\?rss', '', re.sub(r'\/\?rss\]\]>$', r'', re.sub(r'^<!\[CDATA\[', r'', linkapi))), context=gcontext, timeout = 60).read(240000) # read first 240000 bits of this page
                except IOError:
                  time.sleep(5)
                  reconnect=True
                except ValueError:
                  time.sleep(5)
                  reconnect=True
                except:
                  time.sleep(5)
                  reconnect=True
              if wcount >= 10:
                # raise Exception('infinite loop for link '+linka)
                errmessage= 'infinite loop for link '+linka+'\n'
                print errmessage
                continue
              data = json.loads(metawebchunk)
              # metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'$', r'</body></html>', re.sub(r'^.*</head>', r'', re.sub(r'\n', r"NNNNNN", metawebchunk))))
              # postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
              publishok=False
              publishdeleted=False
              for u in data:
                if re.search('deleted', u):
                  publishdeleted=True
                  break
              if not publishdeleted: # postsoup.find("span",{"class":"score"}):
                postscore=int(data["score"]) # int(re.sub(r' point(|s).*$', '', postsoup.find("span",{"class":"score"}).text))
                hnpubdate=datetime.datetime.fromtimestamp(data["time"]) # datetime.datetime.strptime(re.sub(r'\w+, ', '', re.sub(r' \+.*$', '', item.find("pubdate").text)), '%d %b %Y %H:%M:%S')
                if not (datetime.datetime.now()-hnpubdate).total_seconds() > (datetime.datetime.strptime('17 Jul 2016 00:00:00', '%d %b %Y %H:%M:%S')-datetime.datetime.strptime('1 Jul 2016 00:00:00', '%d %b %Y %H:%M:%S')).total_seconds(): ## check if news più vecchia di 16 giorni
                  if postscore >= minscore:
                    publishok=True
                    if id_exists:
                      c.execute("""DELETE FROM hackernews where hnlink=?""", (linka,))
                      hackernewsDB.commit()
                  else:
                    if not id_exists:
                      tstring = unicodedata.normalize('NFKD', t.string).encode('ascii','ignore')
                      titem=str(item).decode('utf8').encode('ascii','ignore')
                      c.execute("""INSERT INTO hackernews VALUES (?,?,?,?)""", (linka, tstring, titem, isincurrentnews,))
                      c.execute("UPDATE hackernews SET hnitem = replace(hnitem, '\n', '') WHERE hnitem like '%\n%'")
                      hackernewsDB.commit()
                else: 
                  if id_exists:
                    c.execute("""DELETE FROM hackernews where hnlink=?""", (linka,))
                    hackernewsDB.commit()
                  else:
                    if postscore >= 200:
                      publishok=True
              if publishok:
                titem=str(item).decode('utf8').encode('ascii','ignore')
                item=re.sub(r'NNNNNNN','\n', re.sub(r'Comments', 'Original Story', re.sub(r'<a href=\"'+re.escape(l.text), '<a href=\"'+originallinks[j].text, re.sub(re.escape(originallinks[j].text), l.text, re.sub(r'\n','NNNNNNN', titem)))))
              else:
                itemposttagsok=False
              c.close()
              hackernewsDB.close()
        if ('lxer' in url) and ('http://lxer.com/module/newswire' in l.text):
          linka=re.sub(r'$', '/index.html', re.sub(r'^http://lxer.com/module/newswire/ext_link.php\?rid=', 'http://lxer.com/module/newswire/view/', l.text))
        else:
          linka=l.text
        reconnect=True
        wcount=0
        while reconnect and wcount < 10:
          try:
            reconnect=False
            wcount = wcount + 1
            metawebchunk = urllib2.urlopen(re.sub('\?rss', '', re.sub(r'\/\?rss\]\]>$', r'', re.sub(r'^<!\[CDATA\[', r'', linka))), context=gcontext, timeout = 60).read(240000) # read first 240000 bits of this page
          except IOError:
            time.sleep(5)
            reconnect=True
          except ValueError:
            time.sleep(5)
            reconnect=True
          except:
            time.sleep(5)
            reconnect=True
        if wcount >= 10:
          # raise Exception('infinite loop for link '+linka)
          errmessage= 'infinite loop for link '+linka+'\n'
          print errmessage
          continue
        if 'lxer' in url:
          if ('http://lxer.com/module/newswire' in linka):
            metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'$', r'</body></html>', re.sub(r'^.*</head>', r'', re.sub(r'\n', r"NNNNNN", metawebchunk))))
            postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
            newstypes=re.sub(r'\n', '', re.sub(r'^.*Story Type: ', '', re.sub(r'; Groups:.*$', '', postsoup.find(lambda tag: tag.name=='table' and tag.has_attr("bgcolor") and tag['bgcolor']=="#fefefe").find('td').text))).split(", ")
            if os.environ.get('INCLUDEPOSTTAGS'):
              for c in newstypes:
                if re.search(includeposttagslist, c,flags=re.IGNORECASE):
                  itemposttagsok=True
                  break
            if os.environ.get('EXCLUDEPOSTTAGS'):
              for c in newstypes:
                if re.search(excludeposttagslist, c,flags=re.IGNORECASE):
                  itemposttagsok=False
                  break
            if itemposttagsok:
              categosx=False
              try:
                categos=re.sub(r'\n', '', re.sub(r'^.*Groups.', '',  re.sub(r'\xab.*$', '', postsoup.find(lambda tag: tag.name=='table' and tag.has_attr("bgcolor") and tag['bgcolor']=="#fefefe").find('td').text))).split(", ")
                categosx=True
                if 'Read more about' in categos[0]:
                  categosx=False
              except AttributeError:
                print "Could not convert data to an integer."
              if categosx:
                if os.environ.get('INCLUDEPOSTTAGS'):
                  for c in categos:
                    if re.search(includeposttagslist, c,flags=re.IGNORECASE):
                      itemposttagsok=True
                      break   
                if os.environ.get('EXCLUDEPOSTTAGS'):
                  for c in categos:
                    if re.search(excludeposttagslist, c,flags=re.IGNORECASE):
                      itemposttagsok=False
                      break
              else:
                itemposttagsok=True
          if itemposttagsok and ('http://lxer.com/module/newswire' in linka):
            if not re.search(excludelinkslist, redirlinks[j].text, flags=re.IGNORECASE):
              item=re.sub(r'NNNNNNN','\n',re.sub(re.sub(r'\?', '\\\?',linka),re.sub(r'\?', '\\\?',redirlinks[j].text),re.sub(r'\n','NNNNNNN',str(item).decode('utf8').encode('ascii','ignore'))))
            else:
              itemposttagsok=False
        if 'nuovavenezia' in url:
          itemok=False
          if re.search(ur'{0}'.format(includetitles), tounicodestr(t.text), flags=re.IGNORECASE|re.UNICODE):
            itemok=True
            if re.search(ur'{0}'.format(excludetitles), tounicodestr(t.text), flags=re.IGNORECASE|re.UNICODE):
              itemok=False
          metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'</head>.*', r'</head><body></body></html>', re.sub(r'\n', r"NNNNNN", metawebchunk)))
          postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
          if postsoup.find("meta",{"name":"tags"}):
            tags=postsoup.find("meta",{"name":"tags"})['content']
            tags=re.sub(r",$", r'', tags)
            categos = tags.split(",")
            if os.environ.get('INCLUDEPOSTTAGS'):
              for c in categos:
                if re.search(includeposttagslist, c,flags=re.IGNORECASE):
                  itemposttagsok=True
                  break   
            if os.environ.get('EXCLUDEPOSTTAGS'):
              for c in categos:
                if re.search(excludeposttagslist, c,flags=re.IGNORECASE):
                  itemposttagsok=False
                  break
          else:
            itemposttagsok=True
          categosxa=False
          try:
            description=postsoup.find("meta",{"name":"description"})['content']
            categosxa=True
          except:
            pass
          if categosxa:
            if not (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
              if re.search(includetitles, description):
                itemok=True
                if not (excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
                  if re.search(excludetitles, description):
                    itemok=False
            if ((excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn") and (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn")):
              itemok=True
        if 'Makeuseof' in url:
          metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'<body>.*<body', r'<body', re.sub(r'^.*</head>(.*)', r'<\!DOCTYPE html>\n<html lang="en" xmlns:fb="http://ogp.me/ns/fb#">\n<head></head>\1</body></html>', re.sub(r'\n', r"NNNNNN", metawebchunk))))
          postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
          catego=re.sub(r'^.*makeuseof.com/service/(.*)/', r'\1', postsoup.find("div",{"class":"category"}).find('a')['href'])
          if not re.search(excludeposttagslist, catego, flags=re.IGNORECASE):
            itemposttagsok=True
        if 'lescienze' in url:
          itemposttagsok=True
          metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'<body>.*<body', r'<body', re.sub(r'^.*</head>(.*)', r'<\!DOCTYPE html>\n<html lang="en" xmlns:fb="http://ogp.me/ns/fb#">\n<head></head>\1</body></html>', re.sub(r'\n', r"NNNNNN", metawebchunk))))
          postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
          categos=[string.contents[0] for string in postsoup.find("div",{"class":"article-maincol"}).find_all('a',{"class":"articolo"})]
          if os.environ.get('EXCLUDEPOSTTAGS'):
            for c in categos:
              if re.search(excludeposttagslist, c,flags=re.IGNORECASE):
                itemposttagsok=False
                break
          if os.environ.get('INCLUDEPOSTTAGS'):
            for c in categos:
              if re.search(includeposttagslist, c,flags=re.IGNORECASE):
                itemposttagsok=True
                break
        if 'ilpost' in url:
          subheading = re.sub(r'</p>.*$','',re.sub(r'^<p>',r'', re.sub(r'\n',r'NNNNNNNNNNN',item.find('description').text)))
          if not (excludetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
              if not re.search(ur'{0}'.format(excludetitles), tounicodestr(subheading), flags=re.IGNORECASE|re.UNICODE):
                itemposttagsok=True
          if not (includetitles == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
            if re.search(ur'{0}'.format(includetitles), tounicodestr(subheading), flags=re.IGNORECASE|re.UNICODE):
              itemposttagsok=True
          metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'<body>.*<body', r'<body', re.sub(r'^.*</head>(.*)', r'<\!DOCTYPE html>\n<html lang="en" xmlns:fb="http://ogp.me/ns/fb#">\n<head></head>\1</body></html>', re.sub(r'\n', r"NNNNNN", metawebchunk))))
          postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
          try:
            section=re.sub(r'^.*www.ilpost.it/(.*)/', r'\1', postsoup.find("h1",{"class":"site-title"}).find('a')['href'])
          except:
            section='none'
          possiblesections='(libri)'
          if re.search(possiblesections, section, flags=re.IGNORECASE):
            itemok=True
            itemposttagsok=True
            if ( len(cats) > 0 ):
              if not (excludetags == "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"):
                for eee in cats:
                  if re.search(excludetags, eee.text, flags=re.IGNORECASE):
                    itemok=False
        if 'lifehacker' in url:
          itemposttagsok=True
          metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'</head>.*', r'</head><body></body></html>', re.sub(r'\n', r"NNNNNN", metawebchunk)))
          postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
          if (postsoup.find("meta",{"name":"keywords"})) and (postsoup.find("meta",{"name":"keywords"})['content']):
            categos=postsoup.find("meta",{"name":"keywords"})['content'].split(", ")
            if os.environ.get('EXCLUDEPOSTTAGS'):
              for c in categos:
                if re.search(excludeposttagslist, c,flags=re.IGNORECASE):
                  itemposttagsok=False
                  break
            if os.environ.get('INCLUDEPOSTTAGS'):
              for c in categos:
                if re.search(includeposttagslist, c,flags=re.IGNORECASE):
                  itemposttagsok=True
                  break
        if 'mymodernmet' in url:
          mymodernmettitlesfile=rssdir+'/'+'_mymodernmettitles.sql'
          if not os.path.exists(mymodernmettitlesfile):
            createDB=True
          else:
            createDB=False
          mymodernmettitleDB = dbapi.connect(mymodernmettitlesfile)
          c = mymodernmettitleDB.cursor()
          if createDB:
            c.execute("""create table mymodernmettitles (title text COLLATE NOCASE)""")
          tstring = unicodedata.normalize('NFKD', t.string).encode('ascii','ignore')
          c.execute("""SELECT * FROM mymodernmettitles WHERE title LIKE '%{my_str}%' COLLATE NOCASE""".format(my_str=re.sub(r'\'', '\'\'',tstring)))
          id_exists = c.fetchone();
          if id_exists:         #### any(re.match(re.escape(tstring), x, flags=re.IGNORECASE) for x in mymodernmettitleslines):
            continue
          else:
            itemposttagsok=True
            metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'<body>.*<body', r'<body', re.sub(r'^.*</head>(.*)', r'<\!DOCTYPE html>\n<html lang="en" xmlns:fb="http://ogp.me/ns/fb#">\n<head></head>\1</body></html>', re.sub(r'\n', r"NNNNNN", metawebchunk))))
            postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
            if postsoup.find("div",{"class":"entry-tags pull-left"}):
              categos=[string.contents[0] for string in postsoup.find("div",{"class":"entry-tags pull-left"}).find_all('a')]
              if os.environ.get('EXCLUDEPOSTTAGS'):
                for ee in categos:
                  if re.search(excludeposttagslist, ee,flags=re.IGNORECASE):
                    itemposttagsok=False
                    break
              if os.environ.get('INCLUDEPOSTTAGS'):
                for ee in categos:
                  if re.search(includeposttagslist, ee,flags=re.IGNORECASE):
                    itemposttagsok=True
                    break
            if itemposttagsok and itemok:
              c.execute("""INSERT INTO mymodernmettitles (title) VALUES (?)""", (tstring,))
              mymodernmettitleDB.commit()
          c.close()
          mymodernmettitleDB.close()
        if 'IeeeSpectrum' in url:
          itemposttagsok=True
          categos=re.sub(r'^(.*)\/.*$', r'\1', re.sub(r'http...spectrum.ieee.org.', '', l.text)).split("/")
          if os.environ.get('EXCLUDEPOSTTAGS'):
            for c in categos:
              if re.search(excludeposttagslist, c,flags=re.IGNORECASE):
                itemposttagsok=False
                break
          if os.environ.get('INCLUDEPOSTTAGS'):
            for c in categos:
              if re.search(includeposttagslist, c,flags=re.IGNORECASE):
                itemposttagsok=True
                break
      else:
        itemposttagsok=True
      if (itemok and itemposttagsok):
        print(unicodedata.normalize('NFKD', t.text).encode('ascii','ignore'))
        itemx=str(item)+'\n'
        rssxmllines.insert(itemlineindex, itemx)
        newscount += 1
        articleincluded=' --> INCLUDED IN RSS FEED'
      databasearticle2write.write(str(re.sub(r'\?', '.', re.sub(r'\?utm_source=.*$', '', re.sub('\?rss','', re.sub(r'$', r'</link>', re.sub(r'^', r'<link>', re.sub(r'\/\?rss\]\]>$', r'', re.sub(r'^<!\[CDATA\[', r'', l.text))))))))+articleincluded+'\n')
      
      
    if 'news.ycombinator' in url:
      print '<---- searching in past news database...'
      hackernewslinksfile=rssdir+'/'+'_hackernewslinks.sql'
      hackernewsDB = dbapi.connect(hackernewslinksfile)
      c = hackernewsDB.cursor()
      c.execute("""SELECT hnlink FROM hackernews where hnisincurrentnews=?""", (1,))
      for dblink in c.fetchall():
        if not any(re.match(dblink[0], l.text, flags=re.IGNORECASE) for l in links):
          c.execute("""UPDATE hackernews SET hnisincurrentnews = replace(hnisincurrentnews, '1', '0') where hnlink=?""", (dblink[0],))
          hackernewsDB.commit()
      c.execute("""SELECT hnlink,hntitle,hnitem FROM hackernews where hnisincurrentnews=?""", (0,))
      for dbhn in c.fetchall():
        linka=dbhn[0]
        linkapi=re.sub('$', '.json?print=pretty', re.sub(re.escape('https://news.ycombinator.com/item?id='), 'https://hacker-news.firebaseio.com/v0/item/', linka))
        tstring=dbhn[1]
        item=BeautifulSoup(dbhn[2], 'html.parser')
        reconnect=True
        wcount=0
        while reconnect and wcount < 10:
          try:
            reconnect=False
            wcount = wcount + 1
            metawebchunk = urllib2.urlopen(re.sub('\?rss', '', re.sub(r'\/\?rss\]\]>$', r'', re.sub(r'^<!\[CDATA\[', r'', linkapi))), context=gcontext, timeout = 60).read(240000) # read first 240000 bits of this page
          except IOError:
            time.sleep(5)
            reconnect=True
          except ValueError:
            time.sleep(5)
            reconnect=True
          except:
            time.sleep(5)
            reconnect=True
        if wcount >= 10:
          # raise Exception('infinite loop for link '+linka)
          errmessage= 'infinite loop for link '+linka+'\n'
          print errmessage
          continue
        data = json.loads(metawebchunk)
        # metawebchunkhead = re.sub(r"NNNNNN", r'\n', re.sub(r'$', r'</body></html>', re.sub(r'^.*</head>', r'', re.sub(r'\n', r"NNNNNN", metawebchunk))))
        # postsoup = BeautifulSoup(metawebchunkhead, 'html.parser')
        publishdeleted=False
        for u in data:
          if re.search('deleted', u):
            publishdeleted=True
            break
        if not publishdeleted: # postsoup.find("span",{"class":"score"}):
          postscore=int(data["score"]) # int(re.sub(r' point(|s).*$', '', postsoup.find("span",{"class":"score"}).text))
          hnpubdate=datetime.datetime.fromtimestamp(data["time"]) # datetime.datetime.strptime(re.sub(r'\w+, ', '', re.sub(r' \+.*$', '', item.find("pubdate").text)), '%d %b %Y %H:%M:%S')
          if not (datetime.datetime.now()-hnpubdate).total_seconds() > (datetime.datetime.strptime('17 Jul 2016 00:00:00', '%d %b %Y %H:%M:%S')-datetime.datetime.strptime('1 Jul 2016 00:00:00', '%d %b %Y %H:%M:%S')).total_seconds(): ## check if news più vecchia di 16 giorni
            if postscore >= minscore:
              originallinka=data["url"]
              titem=str(item).decode('utf8').encode('ascii','ignore')
              item=re.sub(r'NNNNNNN','\n', re.sub(r'Comments', 'Original Story', re.sub(r'<a href=\"'+re.escape(linka), '<a href=\"'+originallinka, re.sub(re.escape(originallinka), linka, re.sub(r'\n','NNNNNNN', titem)))))
              print(tstring)
              itemx=str(item)+'\n'
              rssxmllines.insert(itemlineindex, itemx)
              newscount += 1
              articleincluded=' --> INCLUDED IN RSS FEED'
              databasearticle2write.write(str(re.sub(r'\?', '.', re.sub(r'\?utm_source=.*$', '', re.sub('\?rss','', re.sub(r'$', r'</link>', re.sub(r'^', r'<link>', re.sub(r'\/\?rss\]\]>$', r'', re.sub(r'^<!\[CDATA\[', r'', linka))))))))+articleincluded+'\n')
              c.execute("""DELETE FROM hackernews where hnlink=?""", (linka,))
              hackernewsDB.commit()
          else: 
            c.execute("""DELETE FROM hackernews where hnlink=?""", (linka,))  ### story has been flagged
            hackernewsDB.commit()
        else:
          c.execute("""DELETE FROM hackernews where hnlink=?""", (linka,))
          hackernewsDB.commit()
      c.close()
      hackernewsDB.close()

      
    databasearticle2write.close()
    rssxmllines = "".join(rssxmllines)
    rssxml2write = open(rssxml, 'w')
    rssxml2write.write(rssxmllines)
    rssxml2write.close()

    if newscount >0:
      reconnect=True
      wcount=0
      while reconnect and wcount < 10:
        try:
          reconnect=False
          wcount = wcount + 1
          pingreply = os.system("ping -c 1 " + "nestukh.uni.cx"+ " >/dev/null 2>&1")
          if pingreply == 0:
            pass #  print 'connection is up'
          else:
            print 'connection down, retrying..'
            time.sleep(5)
            reconnect=True
        except IOError:
          time.sleep(5)
          reconnect=True
        except ValueError:
          time.sleep(5)
          reconnect=True
        except ConnectionError:
          time.sleep(5)
          reconnect=True
        except:
          time.sleep(5)
          reconnect=True
      if wcount >= 10:
        raise Exception('infinite loop')
      reconnect=True
      wcount=0
      while reconnect and wcount < 10:
        try:
          reconnect=False
          wcount = wcount + 1
          response = requests.post(pubsubhubbub_Hub_Server, data = {'hub.url': rssxmlurl, 'hub.mode': 'publish'}, timeout=60)
        except IOError:
          time.sleep(60)
          reconnect=True
        except ValueError:
          time.sleep(60)
          reconnect=True
        except ConnectionError:
          time.sleep(60)
          reconnect=True
        except:
          time.sleep(60)
          reconnect=True
      if wcount >= 10:
        raise Exception('infinite loop')
      # curl -X POST "pubsubhubbub_Hub_Server' -d'hub.url=rssxmlurl' -d'hub.mode=publish' -D-
      # You can submit multiple URLs per ping, either by using an array syntax like hub.url[]=<url1> and hub.url[]=<url2>, or by sending a coma separated list or url-encoded URLs like this hub.url=<url1>;<url2>.
      if response.status_code == 204:
        print "----> news push-published" # pass # As a spam filtering measure, superfeedr server will always return 204 when you ping it. Superfeedr analytics lets you visualise successful pings received on your hub.
      else:
        print "error: news not push-published; response status code: "+str(response.status_code)
    return 0
  except Exception, err:
    errmessage='Caught an exception with'+' '+url+' '+':' + '\n' + str(err) + '\n' + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + '\n' + PrintException()
    print errmessage
    errlog='/media/usbstorage/download/RSSfilter_errlog.txt'
    detouch(errlog)
    errlog2write = open(errlog, 'a')
    errlog2write.write(errmessage+'\n'+'\n')
    errlog2write.close()
    return 1
  finally:
    pass

if __name__ == '__main__':
  sys.exit(main())
  
  
END
}









tfolder="/media/usbstorage/download"
tfolderprov="/media/usbstorage/incomplete/RSSFilter"
tinusefolder="/media/usbstorage"
inusefile="$tinusefolder/rsstorrent_in_use"

rssfolder="$HOME/public_html/RSSs"
mkdir -p "$tfolder"
mkdir -p "$tfolderprov"
mkdir -p "$tinusefolder"
mkdir -p "$rssfolder"





if [[ -f "$inusefile" && ( "$(ps -ef | grep curl | grep -v grep | grep globoff)" != "" || "$(ps -ef | grep aria2c | grep -v grep)" != "" ) ]] ; then
  echo "other Series Torrent Downloader Script is currently operating"
  exit 0
else 
  echo "no other Series Torrent Downloader Script currently operating";echo;echo;
  touch "$inusefile"
fi



declare -a rssfeeds=(hackernews arstechnica ilpost LegaNerd technologyreview Makeuseof attivissimo hackaday nuovavenezia streetartnews lescienze spectrumieee mymodernmet maketecheasier lffl) # italians fromquarkstoquasars futurism lifehacker lxer
for r in "${rssfeeds[@]}"; do
  unset rssfeed
  unset tagexclude
  unset taginclude
  unset titleexclude
  unset titleinclude
  unset posttagsinclude
  unset posttagsexclude
  unset linkinclude
  unset linkexclude
  unset multifeed

  case "$r" in
    ilpost)
      rssfeed='http://www.ilpost.it/feed/'
      tagexclude="(post-it|Sport|[Pp]olitica|[Mm]oda|blog|cinque.minuti.off|[Ff]oto del giorno|auto|virgolette|photogallery|mini|fotografia|star wars|cit|instagram|weekly.beasts|caccia|migranti|mostr[ae]|libri per bambini|foto.dello.speciale|fda|foto.animali|weekly.beasts|isis|automobili)" # Video
      taginclude="(cibo|scienza|spazio|libri|giochi.da.tavolo|intelligenza.artificiale)"
      titleexclude="(Le migliori foto di oggi|Perché|streaming|(il|I) video|$(LANG=en_US date '+%Y')|$(date --date='today + 1 year' '+%Y')|$(date --date='today - 1 year' '+%Y')|salvataggio|un accordo|governo unico| cantato|cantata da|Come nascono|Che succede|della (sinistra|destra)|per giovani|caso politico|misure straordinarie|di cui parlano tutti| dell.anno|Non importa se|mila euro|Cosa succede se|attori famosi|da sopra|buone feste|graziato|rapimento|tempesta|intervista d|regal(i|o)|accordo in |sauditi|Tutt(a|e) (le|la) stori(a|e) d(i|el|ei|elle|ella|ello|egli)|Zika|marmotta|giunta militare|controllo sul paese|fotogenica|un reato?|Cosa sappiamo su|governando|meme|al mondo|festival|successo d(i|el|ei|elle|ella|ello|egli)|per (un |)errore|libri da colorare|Spotify|Una giornata|ci prova|Berlusconi|Le cose da sapere su|ostaggi(|o)|lascerà la direzione|molta fatica|soffrire|doloros|Quella d(i|el|ei|elle|ella|ello|egli)|matrimoni gay|alluvion|coming out|transgender|treno di Natale|saldi|battaglia di|In difesa di|La fine d(i|el|ei|elle|ella|ello|egli)| strag(e|i)|nel giorno di Natale| arrivato| arm(a|i)|è avanti|assalto|iniziato un procedimento|carcassa|Gomorra|dove eravamo rimasti|balena|arenat|Vigilie|MotoGP|alle \d\d|Gran Premio|festa della mamma|ciclist|più cattiv|corre sul circuito|\d+ cose che|non sapete di|poter fare con|Messenger|Motomondiale|DiCaprio|immigrazione|Stasera|A Cuba|Audible|Sentiremo parlare di|impeachment|Hyperloop|divieto di circolazione|blocco del traffico|"`
      `"Le cose da sapere su|comprare i biglietti|Lo spot|guasto di|WhatsApp|chi (.|sono) |La storia raccontata da|pene|postin|fake|giornalismo|satir|lotta di classe|contesa|vanno male|Grammy|le gang|endorsement|ha(|nno) trent.anni|bufala|Tra i ghiacciai|I cani|Cyber Monday|tappe|Equitalia|suicidarsi|sta vincendo|Grillo|Cosa succede tra|peggior modo possibile|ricchi|allungare le gambe|Guida di sopravvivenza|tour|Ku Klux Klan|cose su|dall.alto|il momento di|liberist|globalizz|parata|Una vita da|Arabia Saudita|ha copiato|un tizio|social network|Festa della Donna|reciterà (in|nel)|Che fine fa|sparizione|Contro il mito|grande storia|La soluzione per|Russia|Che cosa farebbe(|ro)|Sundance|più grosso del mondo|Che si dice d(i|el|ei|elle|ella|ello|egli)|e gli altri|Invalsi|student|il finale|inverno del|Padre Pio|Cosa . successo|inizia (il|la)|Baghdad|solstizio d’inverno|teaser|Miss Universo|matrimoni gay|trailer|Com.era(|no)|negli anni|nuovo muro|integrazione|pescatori|monaci|Unione Europea|Annalena Benini|è stato venduto|Il mercato|cadaver|Il problema|la finale di|DASPO|Com.è la situazione|Coppa Italia|voragine|terremot|ha chiuso|[Aa]rrestat(o|a|i|e)|bomba|Corea del Nord|Kim Jong-un|Quanto costano|morire|Trump|tritur|pulcin|approvata la legge|Foto con|video|Scientology|Ringraziamento|Weekly Beasts|referendum|"`
      `"ha(|nno) deciso|Film| sparato|nuovo EP|cantante|Da quando|Chi ha sbagliato|Uno dei migliori|populismo|sabbatic|milioni di dollari|Venezuela|non vuol dire pi.|l.ISIS|Siri|da tenere d.occhio|attor(i|e)|Yahoo|attric(e|i)|furt(o|i)|Celebripost|blocco delle auto|Guns....Roses|convention|Trump|comizio|calcio|Siria|vendut(o|a|i|e)|\d+ anni oggi|\d+ anni da|conferenza di pace|tregua|trattato di|Quanto conta|armistizio|Come si vive|Come vedere|Iran|Peanuts|Doonesbury|PCI|vita di|prime pagine di oggi|Che ne . stato d.|Pippo Baudo|video d(i|el|ei)|iracheno|prima pagina di|fotografie d(i|el|ei)|rinviat(o|a|i|e) a giudizio|aereo.*caduto|pi. pagat|foto pi. belle|foto d(i|el|ei|egli|elle|ella|a|alla|alle|agli|ai)|[Bb]ombarda|Alla maturità|scandalo in|a \d+ giorni dal voto|La nuova|Il nuovo|I nuovi|le nuove|stat(o|a) interrott(o|a)|in streaming|è reato?|. foto|crimin(e|i|ali|ale)|uccis(o|a|e|i)|nuovo numero|terrorismo|Serie A|[Aa]llaga|nuovo singolo|inchiesta|indagin(i|e)|Clinton|Chi ha inventato|ballottaggi|raffreddore|influenza|omaggio|Il nuovo calendario|Il Foglio|degli iPhone|(ha|i|hanno) \d+ anni|ebola|(si|) candida(|to|ta|ti|te)|dittatore| testimonianza|cannabis|marijuana|tribunale|X-Files|nuovo iPhone|Africa|pesc. d.aprile|"`
      `"massacro|colpevole| innocente|Saviano|De Magistris|suicid|inaccessibile|rapiment|Pinterest|principess. Disney|David Bowie|vacanza di massa|per i dipendenti|romanzi rosa|FCA|Fiat|Chrysler|sta andando meglio|contenere la perdita|procrast|Giornata della Terra|Game of Thrones|festeggia|Continuano le ricerche|sparit. da|sversamento del petrolio| rapit|trailer|dimess|primo ministro|[Rr]ifugiati]|controvers[oa]|pensioni|TIM| vuole |Riina|Porta a porta| vogliono |naufrag|drog(a|he)|mozzat|Brexit|per profani|Le più belle frasi|lo sappiamo grazie|da dove salta fuori|iraq|siria|intervenire in|funzionano\?|San Valentino|exit poll|YouTube Red|Donald Trump|canali Sky|autopsia|giornata agitata|Cosa succede ora|Le ultime su|copertina d(i|el|ei)|Cosa si sa d(i|el|ei|elle|ella|ello|egli)|[Aa]silo|ddl|unioni civili|emendamento|La tv|prime pagine|Le prime fotografie|protesta d(i|el|ei|elle|ella|ello|egli)|guerra in|sparatori(e|a)|Amazon Prime Day|esplosion(e|i)|senza governo|stormtroopers|Big Ben|per diversi mesi|precipitato|primo singolo|nuovo singolo|omeopat|nuovo album|cangur.|Democratici|Repubblicani|ultimo disco|suicidi(|o)|omosessuali|Su cosa litigano|Papa|disegni di|ha rifatto|prezzo della benzina|Perché Apple|inchiesta|Quali sono|Che Tempo Che Fa| arresti|così piacevole|cover di|cosa seria|Si parla di|(le|i|gli) \d+ migliori|I \d+ anni|di Milano|per chi non soffre di|una cosa per|Una scena di|indagin|FOIA|abort|riaquisir(e|à|anno)|raggiunto un accordo|A che punto|A cosa serve|ha vinto alla Berlinale|prigionier(o|i|a|e)|attentat(o|i)|attacc(o|hi)|il giorno dopo|homepage|nuovo presidente|Parlamento|in testa alle classifiche|incendi(|o)|nuovo proprietario|terrorist(a|e|i)|rifugiat(i|o|a|e)|[Ss]tupr|Cronache|Che fine ha(|n|nno) fatto|nt.anni |le cose certe|sesso|Giornate agitate|manifestazioni|Chi era|formare un governo|si festeggia|Cosa sta succedendo|Come mai|[Ii]ncendio|gran bella sorpresa|spoiler|ora che è uscito|sta piancendo|non uscirà più|del volo |Urbano Cairo|Ciao ciao|xiaomi|Magistratura|tangentopoli|in recessione|comprat|"`
      `"nuovo disco|[Aa]ccoltell|sciopero|fatto causa|730|Palestina|Snapchat|cose strane|che succedono|presidente|sono in crisi|giornali di oggi|Israele|Oscar|make up|Iraq|La storia unica|bellissim|la classe del|della settimana|foto di animali|Dove ha(|nno) sbagliato|Apple ha |cattivissimo|famosissim|fuochi d.artificio|si complica|porno|diceva|Dobbiamo|Le serie tv che sono state cancellate|liberat(i|o|a|e)|sciiti|step(.|)child.adoption|adozion|aumentati i prezzi|luned|marted|mercoled|gioved|venerd|sabat|domenic|sunniti|squalo|Family Day|carcere|Auschwitz|tsunami|nazis(t|m)|Circo Massimo|record d.incass|storia vera|Da dove arriva|articoli più letti|Felice anno nuovo|Fidel Castro|fotografat|riconquistato|curdi|Ci sono novità|muoiono|uragano|sanzioni|Il video (che|di)|controproposte|suoner(anno|à)|disastro|nella storia d.Italia|diossina|secol(o|i) fa|\d+ anni fa|È sparit|sono sparit|Repubblica|Justin Bieber|matrimon|Com(.è|e sono) fatt(o|i|a|e)|incidente |In Italia |Un anno di|Breve storia|pastafarianesimo|Cosa succede (a|in|su|da)|tifone|nat(o|a|i|e) oggi|blocco.*del traffico|soldat(o|i|e)|corruzione|condannant|che abbiate mai visto|battibecc(o|hi)|violenz(e|a)|uccision(i|e)| contro |cessate il fuoco|[Tt]erremoto|prigion(e|i)|nebbia|L.indipendenza d(i|el|ei|elle|ella|ello)|BAFTA|spia|Apple Watch|Avere |Renzi|Twitter|Saviano|eutanasia|soli uomini|disturbi mentali|Cartolin|regalano Internet|agenzia di stampa|l.accordo|si vota in|omicidio|Il principe|Come vanno le cose in|spacciat(o|a|i|e)|comprerà|amministratore delegato|colloqui di pace|"`
      `"Ucraina|franchismo|in diretta tv|doodle|che c'è oggi|Tempi duri|[Qq]uell[ei] che|il più famoso|Antonio Pascale|Perché è famoso|biodinamic|centenario| primarie|Sanremo|Laura Pausini|embrion|mafia|tavole di|abbattuto|giorni festivi|leggenda d(i|el|ei|elle|ella|ello)|nuova canzone d(i|ella|ei|elle)| canzon(e|i)|canzoni d(i|ella|ei|elle)|belle immagini|circonci|[Gg]uai(|o)|Come se la passa|questa sera|elezioni| scontri |Star Wars|Breve guida|Turchia|detenzione|detenut(o|a|i|e)|(non|) ha(|nno|n) (non|) vinto (|la destra|la sinistra|i liberali|il centrodestra|il centrosinistra|i progressisti|i conservatori|l.opposizione|l.estrema destra|l.estrema sinistra)|Tanti saluti|Corriere della Sera|rugby|Rolling Stones|Paul McCartney|Roger Waters|Neil Young|gli Who|mila persone|safari|House of Cards|in \d\d immagini|pessim|scars| finora,|licenziato|se la giocano|trailer|processo per|Cosa resta|estradat(o|a|i|e)| nev(e|ica)| crollat|per anziani|Playboy|Jovanotti|problemi d(i|el|ei)|Tesla|Di cosa parla|Cosa (si dice|dicono)|i media| film|[Oo]ra ([Ll]egale|[Ss]olare)|[Aa]ncora|Black Friday|incontro (tra|fra)|poster |golf|Facebook|Awards|zoo|del giorno|Halloween|Dracula|Ramazzotti|Apple|Apple Music|Starbucks|Netflix|si vota|La stagione|FARC |La storia d(i|el|ei|elle|ella|ello|egli)|Cosa.*sta(|nno) facendo|[Pp]roteste|migranti|La volta che|attacco| accus(a|ato|ati|ate|ata)|del mondo|indovinare| mort(o|i|a|e)|app |tifone|tornado|bufera|alluvione|tossicodipendenti|[Aa]llagat[oa]|(dieci|vent|trent|quarant|cinquant|sessant|settant|ottant|novant|cent).anni|sposer.|Pasquetta|La Pasqua|La prova che|auguri|Buona Pasqua)"
      titleinclude="(, spiegat[oa]|[Sc]acchi| libr(o|i|e)|buchi neri|ebook|kindle|libreri|da visitare|posti|spazio|spaziale|Banksy|intelligenza|artificiale|Hacking|hacker|scienz|computer|star trek|gratis|scaricare|accademic|condivisione|sito)"
      posttagsinclude="ACTIVATED"
      posttagsexclude="ACTIVATED"
      ;;
    LegaNerd)
      rssfeed='http://feeds.feedburner.com/LegaNerd'
      tagexclude="(NSFW|trailer|bowling|facepalm|dc.comics|turbofiga|promo|redazione|anniversario|concorso|crossover|fitness.tracker|batman|reboot|power.ranger|shutupandtakemymoney|cacca|simpson|poop emoji|1aprile|teaser|tv series|serie TV|Video|cosplay|racconti|live|Cool Story Bro|zombie|walking.dead|danza|Bonsaikitten|capsule.temporali|memorie|album|ricordi|Bufale|anteprime|marvel|Cazzate|star.wars|deadpool|r.rated|trash|sexy)"
      taginclude="(star trek|linux)"
      titleexclude="(NSFW|Cosplay|Nerd Play Award|baseball|telecronaca|bleach|pacific.rim|VuttanaVisione‬|game.of.thrones|Instagram|bing|ios|zenpad|gear.fit|Motorola Razr|zombie|walking.dead|featurette|kingsman|sul set|wolverine|magnum|nerdwar|lega nerd comics|lega nerd \d\d\.\d|FCA|Fiat|Chrysler|whatsapp|Deapool|fastweb|gardaland|Snapchat|wunderwaffen|in \d+ minuti|Fitbit|sneak.peek|esclusiv|warner.bros|lega.nerd|gundam|xiaomi|record.store.day|dungeon|cosmofarma|exhibition|deezer|evernote|blue.ray|partenza|non convince|selfie|ultraHD|mac os|streaming|diamo il nome|diciassettenne|amore|megapixel|canzon|con itomi|dc.entertainment|telegram|treni|periscope|suicidio|komizaken|Robert Downey|godzilla|Nanoblock|Eva 01|Windows 10|Acer|arf|Microsoft|Rally|warcraft|contest |spionaggio|crowdfunding|nextbit|\\\$|The Rock|Wolf Man|Dwayne Johnson|scontato|videoclip|millennium.falcon|tributo|DVD|intervista|Mad Max| cine|smartphone|huawei|XKCD What if|occult|reich|blade runner|anni dopo|smallville|remake|oscar|dorkness|supercar|contro l.Umanit|non chiamatel|project.ara|iphone \d|twitter|Chewbacca|nippop|spider.man|captain.america|lingerie|Super Bowl|tom clancy|Unboxing|Capitan America|lumia|Parrot|deadpool|horror|Una giornata a|Lega Nerd Shop|X.Men|Superman|Voltron|Sideshow|web.serie|air.guitar|mercato|Sailor Moon|nuov. sigl.|reboot|nuova clip|supergirl|Apple|Spot|Batman|Superman|wonder.woman|NerdPlay Award|ep( |\.)\d+|Netflix|cancellato|cast|Ep. |Indiana Jones|The Line|Suicide Squad|Saturday Night Live|al cinema|impressioni|Lego|nuovo film|visto attraverso|spoiler|nuove immagini|Comic.Con|Lucca Comics|in TV|Auguri|Evento Apple|Zombie|[Tt]railer|Marvel|Promo|Cosplayer|StarWars|Star.Wars|\d+ Bit|Nerdvana|Halloween|Clip.*HD|Facebook|Apple TV|r.i.p.)"
      titleinclude="(Miyazaki|Ghibli)"
      ;;
#       lifehacker)
#         rssfeed='http://feeds.gawker.com/lifehacker/full'
#         tagexclude="(apple|deals)"
#         taginclude=""
#         titleexclude="(\[Deals\]|This Week.s|Deals:|Loan|Black Friday|Open Thread|Ask .n .xpert|[Dd]iscounts|Lifehacker.*Meetup|drawbacks|Facebook|[Hh]alloween)"
#         titleinclude="(Linux)"
#         posttagsinclude="(evil week|personal finance|productivity|Money|programming|gardens|plants|batteries|wallpapers|privacy|alcohol|Career Spotlight|friday fun|strategy|featured bag|writing|DIY|Relationships|theft prevention|stuff we like|weekend roundup|jobs|security|travel|clever uses|fitness|learn to code|knots)"
#         posttagsexclude="(food|health|How I Work|shopping|Kinja Deals|Halloween|OPEN THREAD|updates|pricing|workshop|death|bills|Starbucks|featured desktop|chrome|fixing stuff|woodworking|iphone|apple|featured workspace|openthread|facebook|annoyances|career|electronics|bathroom|vegan|Justice|google now|outdoors|Downloads|Evening Favorites|Download Roundup|deals|sunday showdown|Wills|mac tips|clothing|communication|home buying|Kinja Co-Op|free|rants|LinkedIn|windows|Netflix|video(|s)|ios tips|college|kids|Kotaku|mac.os.x|Home Theater|Candy|learning|driving|meditation|Audio|tell us|Ask an Expert|downloads|Insurance|communication|plumbing|cleaning|lipstick|Highlights|Stress|Shipping|music|amazon|Kinja Roundup|power|obligations|retirement|weekend project|morning.favorites)"      
#         ;;
    technologyreview)
      rssfeed='http://www.technologyreview.com/stream/rss/'
      tagexclude=""
      titleexclude="(Week Ending|Boot Camp|Microsoft|Pok.mon|Obama|Tesla|Brexit|Recommended.*Read|zika|ti porto la luna|tappa |Diabete|Republican|WhatsApp|Comment|Larry Page|Chatbot|from readers|Dumb|Oculus|Health|Mosquito|Tim Cook|Apple|iphone|Zuckerberg|Ideology|terroris|From the Editor|Other Interesting arXiv Papers|driverless|self.driving| car( |$)|Best of the Web|Must-Read Stories|Recommended from Around the Web|Facebook|Spend)"
      titleinclude=""
      ;;
    Makeuseof)
      rssfeed='http://feeds2.feedburner.com/Makeuseof'
      tagexclude="(Deals|Discount|Social Media|Tech News|costumes|Sponsored|Announcements)"
      taginclude="(Android|[Ll]inux|Self Improvement|management|Black Friday|Technology Explained|star trek|[Pp]rogramming|[Ss]ecurity|[Rr]asp)"
      titleexclude="(MakeUseOf Poll|Course Bundle|Collaboration|Working Out|Google Keep|vocemail|Audiobook|Facebook|Explained in \d\d Seconds|Kindle Fire|Make.*Money|Resume|Dyslexia|Safari|(^| )Kid( |$|-)|Apple Mac|Email|Siri|Google Sheets|iPhone Photos|Outlook|course|meditat|Evernote|Emoji|RealPlayer|motivation|for Dad|AliExpress|Snapchat| Outlook( |$)|Google Drive|Tumblr|Trello|Morning|Learn How|Confusing|\d Reasons|Smart Home|Right Now|Which One|do you Really Need|Funniest|Spotify|with These \d|budget|Bluetooth Speaker|BlackBerry|How to Try|Euro Cup|Ruining Your|What You Can Do|facebook|soccer|Success|Happiness|gossip| steam|Office Insider|SmartThings|batman|Refund|decorate|stylish|Suicide Squad|Fitbit|Inbox by Gmail|Waste Less|Bing( |$)|Ubuntu Touch|nuovi uffici|disponibile.in.italia|a.caro.prezzo|Boost Your iOS|Coding Basics|Anytime Soon|How to Stop|Television|Fitness Tracker|Motivat|Achiev.*Goals|Excel Macros|Voice|VBA|google docs|Retire|(in|with) PowerPoint|Quick Tips|Superhero|cv|Movies|Tidal|Google Photo|Microsoft Edge|Microsoft Word|Job Interview|PowerPoint Online|chromebook|MS Edge|Word|financ|Kids|Captain America|Social Media|Learning|Online Subscriptions|save money|Fingerprint| PIN |Thunderbolt|amazon|Picasa|Consider Before|Google.s |Smartwatch|Office 2016|exel|SoundCloud|Loan|YouTube Red|Deadpool|Apple Watch|Adobe|Story|Harmony Elite|Education|Microsoft.s|Star Wars|chrome|OneNote|OnePlus One|Debt|With an iPhone|\d+\\$|\\$\d+|Giving Away|in Chrome with|Chrome Extension|LXDE|Xfce|(To|in) Windows|MATE|Slack|$(LANG=en_US date '+%Y')|$(date --date='today + 1 year' '+%Y')|$(date --date='today - 1 year' '+%Y')|Tech News Digest|Gift(|s)|Poll|Jurassic Park|Black Friday|Get a Free|Facebook|Feedly|In Windows|Instagram|[Gg]iftcard|Trello|Superman|Football|Your Chrome|Office 365|Google Chrome|Selfie|Deals|Microsoft Access|Review and Giveaway|Microsoft Office|Mac Users|Christmas|El Capitan|Halloween|Windows (|10)|Cyber Monday|Tax Software|Facebook|Spotify|Netflix|Microsoft OneNote|iPhone . iPad|Apple TV|Hulu|Discount|iTunes|OneDrive|Social Posts|Excel|Microsoft Outlook)"
      titleinclude="(Android|[Ll]inux|[Ee]book|Self Improvement|management|Technology Explained|star trek|[Pp]rogramming|[Ss]ecurity|[Rr]asp|Free Alternative)"
      posttagsinclude=""
      posttagsexclude="(windows|ios|news|annoucements|mac|social-media|product-reviews|games|sponsored|deals)"
      ;;
    attivissimo)
      rssfeed='http://feeds.feedburner.com/Disinformatico'
      tagexclude=""
      taginclude=""
      titleexclude="(Podcast|Ci vediamo|anni fa|Pok.mon|Badoo|Calma un attimo|Tesla|elon musk|Facebook|È mort|ne parlo su|Almanacco dello Spazio|sarà a|Lugano|Cristoforetti|ufologia|Vado a trovare| radiat|Ti Porto la Luna|Cena dei Disinformatici|fall. di Flash|domani|sabato|Windows|adobe|ospit(i|a|e)|Oggi a|livetweet|conferenza|Samantha|Astrosamantha|[Ss]tasera|parliamo|Hangout|iOS|OS X|Vado a incontrare|discutiamo di|iphone|Apple|Stamattina a|bufal)"
      titleinclude=""
      ;;
#     fromquarkstoquasars)
#       rssfeed='http://www.fromquarkstoquasars.com/feed/'
#       tagexclude=""
#       taginclude=""
#       titleexclude="(Astronomy Photo of the Day)"
#       titleinclude=""
#       ;;
#     futurism)
#       rssfeed='http://futurism.com/'
#       tagexclude=""
#       taginclude=""
#       titleexclude=""
#       titleinclude=""
#       ;;
    hackaday)
      rssfeed='http://hackaday.com/feed/'
      tagexclude="(cons|retrocomputer|workshops|meetup|World.Create.Day|Anything.Goes|contests)"
      taginclude=""
      titleexclude="(Fail of the Week|Apple|Restoring|Last Chance|Makerspace|Opening Night|Opens Its Doors|Macintosh|Maker Faire|ArduinoMan|Workshop|Retro|ubuntu|Windows|Teardown|Bluetooth Speaker|Tearing Down|Links:|[Gg]am[ei]|Hackaday|PowerMac|Apple II|Arcade|Halloween|Pumpkin|Selfie|Kickstarter Scam)"
      titleinclude=""
      ;;
#     italians)
#       rssfeed='http://italians.corriere.it/feed/'
#       tagexclude=""
#       titleexclude=""
#       ;;
    nuovavenezia)
      rssfeed='http://nuovavenezia.gelocal.it/rss/cmlink/rss-nuova-venezia-venezia-cronaca-1.10334773'
      tagexclude=""
      taginclude=""
      titleexclude="(omicidio|Park Granturismo|Carte clonate|Prende fuoco|maestra|Gatti|Investit(o|a|i|e)|genitori|in classe|auto|incidente stradale|rissa|ambulant|Emeroteca|abusiv|Latitante|truffa|banca|muore|A4|tampon|contro un albero|Contratti non conformi|sul palco|coperto dal velo|Festa del lavoro|comunità ebraica|(1|primo) maggio|centr. commercial|sposare|Trattore|in rotonda|conducente|denunce|falsificat|laureat|negozi chiusi|Tower|Spaccio|motocross|aeroporto|spinea|estorsion|insegnant|personale amministrativo|nuov. contratt|Mostra del Cinema|binari|Firme false|SALZANO|Isabella Noventa|polfer|Violenza di genere|Auto |aereo|aerei|Romea|Volo |nudo|famiglia|mutu(o|i)|sostanze stupefacenti|Corpus Domini|Cacche|accordi economici|nvestit(a|o)|borse|selfie|sindacati|Profughi|matrimon|Migrant| tir |nel fosso|Malato terminale|si getta|Adriano Duse|sui monti|intossicat|dopo una cena a|Violentat|gelos|Trapiant|Palacinema|autostrad. chius|A4|netturbin|Vandal|elementare|la Liberazione|supermercat|Rapin|pest|prostitut|parroco|criminalit|profug|dalla moto|crolla|centauro|all.esame|musile|Jesolo|profug|frutta e verdura|coltivaz|lavorator|Noale|asilo|derattizz|ladr|pusher|frontale|obitorio|Pieve di Cadore|Terroris|ZELARINO|rissa|uccider|uccis|Cagn|palestra|can(e|i)|cucciol|volp|tagliola|Piove di Sacco|Chiodi sull.asfalto|Serie D|Il Venezia|zanzare tigre|basket|coltello|Allarme bomb|boxe|Portogruaro|Campagna Lupia|Nomine in tribunale|Distribuzione del gas|Ricorso di Italgas|comico|droga|prostitut|Festival degli aquiloni|Libri arcobaleno|manager a giudizio|contrabbando|tram|Arsenico|muore a|ospedale al Mare|Cartelle per|cartelle esattoriali|sess|caorle|Camorra|Lega Pro|premeditazione|gay|Family friendly|sucid|accoltell|nozze in chiesa|Federalberghi|Abusivi|Lando|Spiagg|Litigio|pugni|calci|Ragazz|boss|antistress|il Giro|noale|panchina dei clochard|centr. social.|carte di credito|Lite tra|ubriac|Cinture di sicurezza|movida|polstrada|"`
      `"Sdraio|ombrelloni|tintarella|spiagge|sequestrat|excort|escort|controllo di  polizia|trovato morto in casa|Cremona|Taliercio|Noventa|denunci|esercito|islam|Rapin|Mort. |Escursionista|Vigili in assemblea|contro.*camion|donano il sangue|tumore|portogruaro|birdman|autostrada chiusa|cricket|(il volo|voli) per|tuffa|auto|vescovo|terrori(s|t)|metro|scherzo|dona.*sangue|fs|partori|pugni|rapina|cesareo|part(o|i) |carcere|funeral|SUSEGANA|tragedia|muore|truff|chat|operai|pedalata|student|dato fuoco|fiamme|per ricordare|Asili|educator|bimb|penitenziar|detenut|educatric|platan|Patto di stabilità|carreggiata|autostrada|furt|fucil|falso allarme|droga|procurato allarme|calzaturif|ospedale di Dolo|cadavere|casello|motociclist|Romea|mercato|portogruaro|Punto nascite|trovarl. viv|acqua San Benedetto|masterizzazione|Martellago|CAMPAGNA LUPIA|vistared|incrocio|servizi ai minori|CAVARZERE|spacciator|spese elettorali|pesc. d.aprile|cani|gatti|terroris(m|t)|Bandit|senolog|davanti a scuola|Caldai|è reato|uccis|mort|banda che ha colpito|pacco sospetto|Festa dei fiori|Radicchio|ferit|giro d.italia|Festa della donna|Forza Italia|ospedale civile|Allarme bomba|piano urbanistico|Trafficant|cane|frod|Mazzett|prof|hard|Mala del Brenta|latitante)"
      titleinclude="(moto.ondoso|mail|gondol|boat|mose|dvd|(^| )voga|regat|laguna|(^| )cavan|catamaran|(^| )vel(a|e|i)|lancion| porto|diporto|Mira|Oriago|Unesco|Biennale|(^| )mar(e|i) |remier|Fresco|(^| )batel|pupparin|caorlin|Canal.Grande|(^| )rem|Naviglio|(^| )barc|Vogalonga|(^| )var(a|o)|acqua.alta|acqu(a|e)|(^| )nav(e|i)|yacht|motoscaf|(^| )rio|idro|(^| )rii|canal|Argos|scioper|Redentore|Riviera|ponte|maratona|Marathon|(^| )alga|alghe|(^| )isol(a|e))"
      posttagsinclude="(grandi navi|mose|moto ondoso|no grandi navi|regatastorica|voga)"
      ;;
    streetartnews)
      rssfeed='http://feeds.feedburner.com/streetart-news'
      tagexclude=""
      taginclude=""
      titleexclude=""
      titleinclude="(Most Popular|Banksy|Deih|Ino|iNO|L7M|Stinkfish|OAKOAK|Jana|Lonac|Mobstr|Shepard Fairey|1010|WD|Hula|Fin DAC|Felice Varini|C215|Faith47|ROA|Smates|Alexis Diaz|Hopare|Venice, Italy)"
      posttagsinclude=""
      ;;
    lescienze)
      rssfeed='http://www.lescienze.it/rss/lanci/rss2.0.xml'
      tagexclude=""
      taginclude=""
      titleexclude="(Sclerosi|promosso a nuova università|celiac|Mutazioni genetiche|bambini|Innovazione|aprono le iscrizioni|adolescenti|imprese|direttore|colesterolo|contro la malattia|nuova terapia|Atrofia|muscolare|finanziamento)"
      titleinclude=""
      posttagsinclude="(agenzie spaziali|Career Development Award|antropologia|astrofisica|astronomia|clima|buchi neri|chimica|comportamento|computer science|cosmologia|economia|etica|filosofia|fisica|fisica delle particelle|fisica teorica|internet|politiche della ricerca|matematica|materiali|rinnovabili|robotica|neuroscienze|percezione|piante|planetologia|psicologia|societ.|spazio|statistica|tecnologia|trasporti|urbanistica|visione)"
      posttagsexclude="(animali|sonno|sport|staminali|agricoltura|apprendimento|bambini|dipendenze|eventi|famiglia|politiche sanitarie|immunologia|primatologia|riproduzione|biologia dello sviluppo|terapie|medicina)"
      ;;
    spectrumieee)
      rssfeed='http://feeds.feedburner.com/IeeeSpectrumFullText'
      tagexclude=""
      taginclude=""
      titleexclude="(Driverless Cars|hyperloop|by \d\d\d\d|Mourn|sport| car(|s) |self-driving| teen|high.school|autonomous vehicles|Apple)"
      titleinclude="(breakthrough|gravitational|gravity|alien|telescope|fusion|solar|startup|gps|planet|e\.t\.|sensor|cryptograph|Einstein|Forecast|Astronom|DIY|detector)"
      posttagsinclude="(artificial-intelligence|robotics|(-| |^)ISIS|robotic-exploration|Local Shops|peeks|history|consumer-electronics|astrophysics|devices|military|security|nanotechnology|space-robots|drones|sitellites|computing|geek-life|energywise|automation|renewables|hardware|test-and-measurement|software|riskfactor|networks|green-tech|wind|diy|standards)"
      posttagsexclude="(cars-that-think|advanced-cars|self-driving|Nuclear|tech-careers|education|gaming)"
      ;;
    mymodernmet)
      rssfeed='http://www.mymodernmet.com/profiles/blogs/feed/featured'
      tagexclude=""
      taginclude=""
      titleexclude="(super(| )bowl|rescue|Valentine's Day|annual|magical|forest|Loving|Dad|Surgery|Scar|Inspir|Self-Confidence|elder|tatoo|pop culture|adorabl|terrarium|college|recycl|types of intelligence|Anyone the Opportunity to Become|woman|adoption|Hyperloop|year-old|boy|humans| Carv|Tiny|Microscopic|Detail|Pencil|around the world|lipstick|women|cheerful|kindergarten|covers|repair|Touching|Victim|for free|dove|art student|father|superhero|educator|dressed|Reimagin|Celebrity|Best Friends|Photoshop|(her|his|their) son|Empty Streets|celebrat|firefl|adults|evacuee|organ |Dignity|homeless|Exquisite| Heels|real|housemate|affectionate|create|painting|Responsibly|pay(|s) tribute|tattoo|fitter|pregnant|helmet|peace|Intricate|Human Form|church|Drawing|years old|transplant|Look Like|Perform(|s) Concert|Spends Over Recreating Iconic|playful|miniature|replica|Jungle|urban|heartfelt|infertil|Unlikely Love|Mermaid|billy.crystal|muhammad.ali|mascot|teacher|student|mother|daughter|Inception|humans.of.new.york|dogs|blog|children|timeless|Bearded|playfully|Barbie|grampa|village| pet |kids|famil|$(LANG=en_US date '+%Y')|$(date --date='today + 1 year' '+%Y')|bird|documents|Photography Assistant|Renewable Energy|spring|Happy|surprise|stranger|disney|vintage|Highlight|close.up|documentary|Interview|Stormtrooper|disabled|surreal|fabulous|stunning|wonderful|motivation|wedding|Couples|portrait|Kissing|pope|Global Teacher Award|adorable|BBQ|Starbucks|yoga|Hilarious|medical|iphone|Magazine|Pup(|py|pies)|Valentine|Heartwarming|Watercolor|Meticulous|dreamy|vixen|vogue|sex|vanity fair|victoria's secret|miss |star wars)"
      titleinclude="(landscape|modern architecture|tasty|edible)"
      posttagsinclude="(space|food|knot|clock|rubik|bokeh|game|chess|trek)"
      posttagsexclude="(dog|love actually|funny|humor|ted|koalas|news|obama)"
      ;;
    lffl)
      rssfeed='http://www.lffl.org/feed'
      titleexclude="(ubuntu.\d\d|cinnamon|Mate|Zorin OS|RC\d|conky|GTK. |pidgin|chromebook|openSUSE|telegram|redhat|centos|rpm|music.player|gnome.shell|Firefox OS|Apple|Saints Row|microsoft|BlackArch|bugfix|rilasciato|Ubuntu edition|dragonfly|Arch | RC(| )\d+|summer code|canonical|Webinar|Hitman|Cuffie|Manjaro|ubuntu.\d\d.|Devuan|CrossOver|enlightenment|MATE|Ubuntu touch|driver|Amazon|sconto|Docker|podcast|Cinnamon|mint|Virtualization|Steam|GNOME|Sabayon|red(.|)hat|Eclipse|Unity|Vivaldi|How to Try| Beta|Opera|LXDE|arch |OwnCloud|Fedora|Slackware|Chrome)"
      titleinclude="(pdf|kde|debian|libreoffice|firefox|bsd|raspian)"      
      ;;
    arstechnica)
      rssfeed='http://feeds.feedburner.com/ArsTechnicaUk' # 'http://feeds.arstechnica.com/arstechnica/index/ http://feeds.feedburner.com/ArsTechnicaUk'
      titleexclude="(apple|fda|Pok.mon|Immune system|lets you|Theranos|gross|money can buy|in mice|gay|Oracle|was a success|precious little|year.old|Buyer beware|deal|disease|Avast|AVG|unveils|struggl|software deal|Brexit|Amazon|dinosaurs|forgets to|may be| render |IBM.s Watson|Mammal|smok(ing|er)|Red Dead Redemption|blood|sales|Microsoft|porn|rumor|Stem cells|restrict|as usual|social media|TV|Windows|Council| hir(e|ing)|Teen|girl|suicid)"
      tagexclude="(Law & Disorder|Infinite Loop|Cars Technica|fda|stem cells|The Multiverse|superhero)"
      titleinclude="(kde|pdf|debian|star.trek|linux|bsd)"
      ;;
    hackernews)
      rssfeed='https://news.ycombinator.com/rss'
      titleexclude="(ubuntu.\d\d|cinnamon|Mate|Friends|Nihilist|Zorin OS|RC\d|conky|GTK. |pidgin|chromebook|openSUSE|telegram|redhat|centos|rpm|music.player|gnome.shell|Firefox OS|Apple|Saints Row|microsoft|BlackArch|bugfix|rilasciato|Ubuntu edition|Valve|Oculus|pre.order|rift|dragonfly|Arch | RC(| )\d+|summer code|canonical|Webinar|Facebook|messenger|Hitman|Cuffie|Manjaro|ubuntu.\d\d.|Devuan|CrossOver|enlightenment|MATE|Ubuntu touch|driver|Amazon|sconto|Docker|podcast|Cinnamon|mint|Steam|pok.mon|turns (\d+|one|two|twent|thir|four|five|fift|six|seven|eight|nin|ten)|Coursera|GNOME|Sabayon|red(.|)hat|Eclipse|Unity|Vivaldi|How to Try| Beta|Opera|LXDE|arch |OwnCloud|Fedora|Slackware|Chrome)"
      titleinclude="(pdf|kde|debian|libreoffice|firefox|bsd|raspian)" 
      posttagsinclude="(wikipedia.org|github.io|github.com|spacetelescope.org)"
      posttagsexclude="(apple.com|arstechnica|bloomberg.com|recode.net|facebook.com|microsoft.com|jupyter.org|hackaday.com|mymodernmet.com|technologyreview.com|rust-lang.org|roadtovr.com|ycombinator.com|spectrum.ieee.org|plos.org|medium.com|npr.org|antirez.com|nypost.com|whoishiring.io)"
      ;;
  esac

  RSSFiltering "$rssfeed" "$tagexclude" "$taginclude" "$titleexclude" "$titleinclude" "$posttagsinclude" "$posttagsexclude" "$linkexclude" "$linkinclude" "$multifeed"
  echo;
  
done



  # filter avaz titoli senza repost
  # http://nestukh.uni.cx:8099/~server/RSSs/lffl.org_feed_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/_www.maketecheasier.com_category_linux-tips_feed_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/lxer.com_module_newswire_headlines.rdf_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/mymodernmet.com_profiles_blogs_feed_featured_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/feeds.feedburner.com_IeeeSpectrumFullText_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/feeds.feedburner.com_Disinformatico_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/feeds2.feedburner.com_Makeuseof_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/feeds.feedburner.com_LegaNerd_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/feeds.gawker.com_lifehacker_full_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/fromquarkstoquasars.com_feed_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/ilpost.it_feed_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/technologyreview.com_stream_rss_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/hackaday.com_feed_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/nuovavenezia.gelocal.it_rss_cmlink_rss-nuova-venezia-venezia-cronaca-1.10334773_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/feeds.feedburner.com_streetart-news_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/lescienze.it_rss_lanci_rss2.0.xml_revisited_rss.xml
  # http://nestukh.uni.cx:8099/~server/RSSs/feeds.feedburner.com_ArsTechnicaUk_revisited_rss.xml ## http://nestukh.uni.cx:8099/~server/RSSs/feeds.arstechnica.com_arstechnica_index_revisited_rss.xml 
  # http://nestukh.uni.cx:8099/~server/RSSs/_news.ycombinator.com_rss_revisited_rss.xml 







rm -f "$inusefile"
echo "all done"


exit 0



  
  




