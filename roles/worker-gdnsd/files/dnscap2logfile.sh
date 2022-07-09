#!/usr/bin/env bash

/usr/local/bin/dnscap -p -g -i $1 2>&1 >/dev/null | python -c '

# [77] 2015-08-27 10:17:33.946801 [#1233 p1p1 4095] \
#         [118.70.1.233].62471 [222.255.27.101].53  \
#         dns QUERY,NOERROR,46697 \
#         1 afamily1-vcmedia.cdn.vccloud.vn,IN,A 0 0 0
# [245] 2015-08-27 10:17:33.946831 [#1234 p1p1 4095] \
#         [222.255.27.101].53 [118.70.1.233].62471  \
#         dns QUERY,NOERROR,46697,qr|aa \
#         1 afamily1-vcmedia.cdn.vccloud.vn,IN,A \
#         2 afamily1-vcmedia.cdn.vccloud.vn,IN,A,15,222.255.27.105 \
#         afamily1-vcmedia.cdn.vccloud.vn,IN,A,15,222.255.27.101 \
#         4 cdn.vccloud.vn,IN,NS,60,ns3.cdn.vccloud.vn \
#         cdn.vccloud.vn,IN,NS,60,ns4.cdn.vccloud.vn \
#         cdn.vccloud.vn,IN,NS,60,ns1.cdn.vccloud.vn \
#         cdn.vccloud.vn,IN,NS,60,ns2.cdn.vccloud.vn \
#         4 ns3.cdn.vccloud.vn,IN,A,60,123.30.215.39 \
#         ns4.cdn.vccloud.vn,IN,A,60,123.30.215.50 \
#         ns1.cdn.vccloud.vn,IN,A,60,222.255.27.101 \
#         ns2.cdn.vccloud.vn,IN,A,60,222.255.27.105

import re
import sys

LINE = ""
for line in sys.stdin:

    # Ghép thành 1 dòng
    LINE += line.strip().strip(" \\") + " "
    if not line.endswith(" \\\n"):
        print LINE
        LINE = ""
' >> $2
