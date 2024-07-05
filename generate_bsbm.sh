#!/usr/bin/env bash

mkdir "bsbm-data"
for DATASET_SIZE in 1000 2500 5000 7500 10000 25000 50000 75000 100000 250000 500000
do
  echo "Generating ${DATASET_SIZE}"
  ./generate -fc -pc ${DATASET_SIZE} -s nt -fn "dataset-${DATASET_SIZE}" -ud -ufn "dataset-update-${DATASET_SIZE}"
  echo "Explore ${DATASET_SIZE}"
  ./testdriver -ucf usecases/explore/sparql.txt http://127.0.0.1:7878/query
  pbzip2 log.csv
  mv log.csv.bz2 "bsbm-data/explore-${DATASET_SIZE}.csv.bz2"
  echo "Explore and update ${DATASET_SIZE}"
  ./testdriver -ucf usecases/exploreAndUpdate/sparql.txt http://127.0.0.1:7878/query -u http://127.0.0.1:7878/update -udataset "dataset-update-${DATASET_SIZE}.nt"
  pbzip2 log.csv
  mv log.csv.bz2 "bsbm-data/exploreAndUpdate-${DATASET_SIZE}.csv.bz2"
  echo "Business intelligence ${DATASET_SIZE}"
  ./testdriver -ucf usecases/businessIntelligence/sparql.txt http://127.0.0.1:7878/query
  pbzip2 log.csv
  mv log.csv.bz2 "bsbm-data/businessIntelligence-${DATASET_SIZE}.csv.bz2"
  echo "End ${DATASET_SIZE}"
  pbzip2 "dataset-${DATASET_SIZE}.nt"
  mv "dataset-${DATASET_SIZE}.nt.bz2" "bsbm-data"
  rm -rf "dataset-update-${DATASET_SIZE}.nt"
  rm -rf td_data
done
