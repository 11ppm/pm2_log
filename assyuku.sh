# for i in {2..10}; do gzip 2-nodeStartPM2-error.log.$i; done
for i in {2..10}; do gzip *log.$i; done
