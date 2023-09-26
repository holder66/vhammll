# command_line_stuff.sh
v -prod .;
./vhamml cross -ms diab1.opts -a 4 -b 1,7 -w datasets/UCI/diabetes.arff;
./vhamml cross -ms diab1.opts -a 2 -b 1,11 -w datasets/UCI/diabetes.arff;
./vhamml cross -ms diab1.opts -a 5 -b 3,3 -w datasets/UCI/diabetes.arff;
./vhamml cross -ms diab1.opts -a 4 -b 2,2 -w datasets/UCI/diabetes.arff;
./vhamml cross -ms diab1.opts -a 1 -b 2,2 -w datasets/UCI/diabetes.arff;
./vhamml cross -ms diab1.opts -a 3 -b 14,14 -w -wr datasets/UCI/diabetes.arff;
./vhamml cross -ms diab1.opts -a 2 -b 2,2 -w -wr datasets/UCI/diabetes.arff;
./vhamml cross -ms diab1.opts -a 1 -b 4,4 -w -wr datasets/UCI/diabetes.arff



./vhamml cross -e -ms ox.opts -a 1 -b 3,3  -w -wr ~/Oxford-train.tab;
./vhamml cross -e -ms ox.opts -a 4 -b 8,8  -w -wr ~/Oxford-train.tab;
./vhamml cross -e -ms ox.opts -a 8 -b 2  -w -wr ~/Oxford-train.tab;
# ./vhamml cross -e -ms ox.opts -a 10 -b 2  -wr ~/Oxford-train.tab;
# ./vhamml cross -e -ms ox.opts -a 10 -b 2  -wr ~/Oxford-train.tab;
# ./vhamml cross -e -ms ox.opts -a 10 -b 2  -wr ~/Oxford-train.tab;
# ./vhamml cross -e -ms ox.opts -a 10 -b 2  -wr ~/Oxford-train.tab;
# ./vhamml cross -e -ms ox.opts -a 10 -b 2  -wr ~/Oxford-train.tab;
# ./vhamml cross -e -ms ox.opts -a 10 -b 2  -wr ~/Oxford-train.tab;
# ./vhamml cross -e -ms ox.opts -a 10 -b 2  -wr ~/Oxford-train.tab;
# ./vhamml cross -e -ms ox.opts -a 10 -b 2  -wr ~/Oxford-train.tab;
