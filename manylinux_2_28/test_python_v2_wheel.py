# this file is intended to be invoked using "/path/to/python test_wheel.py"

import htcondor2 as htcondor
import classad2 as classad

# Test the htcondor module
print(htcondor.version())
try:
    collector = htcondor.Collector()
    ad = collector.query(htcondor.AdTypes.Collector)
except Exception as e:
    print(e)
    sys.exit(1)

if len(ad) == 0:
    print('Did not find any Collector Classads!')
    sys.exit(1)

# Test the classad module
try:
    ad = classad.ClassAd()
    ad['Five'] = 5
    ad['TestExpr'] = classad.ExprTree("Five + 5")
except Exception as e:
    print(e)
    sys.exit(1)

assert ad.eval('TestExpr') == 10
