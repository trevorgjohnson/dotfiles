#!/bin/sh
git branch | cut -c 3- | gum choose --no-limit | xargs git branch -D
