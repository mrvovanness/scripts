#!/bin/bash

#create backup
#ssh weekend_production "pg_dump weekend365_production" > ~/weekend_prod.dump

#restore from backup
psql weekend_production < ~/weekend_prod.dump
