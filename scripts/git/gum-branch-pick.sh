#!/bin/sh
git checkout $(git branch -a | cut -c 2- | gum filter) && git attach
