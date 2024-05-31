# this file is intended to be invoked using "/path/to/python test_wheel.py"

import htcondor
import classad
import sys

print(htcondor.version())

# Test the classad module
try:
    ad = classad.ClassAd()
    ad['Five'] = 5
    ad['TestExpr'] = classad.ExprTree("Five + 5")
except Exception as e:
    print(e)
    sys.exit(1)

assert ad.eval('TestExpr') == 10

# Test the htcondor module
try:
    collector = htcondor.Collector()
    ad = collector.query(htcondor.AdTypes.Collector)
except Exception as e:
    print(e)
    sys.exit(1)

if len(ad) == 0:
    print('Did not find any Collector Classads!')
    sys.exit(1)

