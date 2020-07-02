#!/bin/bash

sed "s/tagVersion/$1/g" pods.yml > kubapppod.yml
