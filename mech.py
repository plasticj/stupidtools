import mechanize, re
import datetime

user = ""
passwd = ""
startdate = datetime.date(2011,01,01)
enddate = datetime.date(2011,12,31)

url = 'https://e-learning.tu-harburg.de/studip/index.php'
cal_url = 'https://e-learning.tu-harburg.de/studip/calendar.php?cmd=export'

br = mechanize.Browser(factory=mechanize.RobustFactory())

br.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)
br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')]
br.set_handle_robots(False)

br.set_debug_redirects(True)
#br.set_debug_responses(True)
#br.set_debug_http(True)

print "starting"
br.open(url)

print "following login link"
br.follow_link(text_regex="Login")
assert br.viewing_html()
#print br.geturl()
#print br.info()  # headers

br.select_form(name="login")
br["loginname"] = user
br["password"] = passwd
print "submitting form"
r = br.submit()
print "ok"
## https://e-learning.tu-harburg.de/studip/calendar.php?cmd=export
print "going to export page"
br.open(cal_url)
assert br.viewing_html()

#br.response.read()
#
#for f in br.forms():
#    print f
br.select_form(name="Formular")
br["extype"] = ["ALL"]
br["experiod"] = ["period"]
br["exstartday"] =  str(startdate.day  )
br["exstartmonth"]= str(startdate.month)
br["exstartyear"] = str(startdate.year )
br["exendday"] =    str(enddate.day    )
br["exendmonth"] =  str(enddate.month  )
br["exendyear"] =   str(enddate.year   )
br.submit()                            
ics = br.response().read()
f = open("studip.ics","w")
f.write(ics)
f.close()
