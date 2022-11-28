# In case your system doesn't have any of these tools:
# https://pypi.python.org/pypi/xml2rfc
# https://github.com/cabo/kramdown-rfc2629
# https://github.com/Juniper/libslax/tree/master/doc/oxtradoc
# https://tools.ietf.org/tools/idnits/

xml2rfc ?= xml2rfc
kramdown-rfc2629 ?= kramdown-rfc2629
oxtradoc ?= oxtradoc
idnits ?= idnits

draft := $(basename $(lastword $(sort $(wildcard draft-*.xml)) $(sort $(wildcard draft-*.md)) $(sort $(wildcard draft-*.org)) ))

ifeq (,$(draft))
$(warning No file named draft-*.md or draft-*.xml or draft-*.org)
$(error Read README.md for setup instructions)
endif

draft_type := $(suffix $(firstword $(wildcard $(draft).md $(draft).org $(draft).xml) ))

current_ver := $(shell git tag | grep '$(draft)-[0-9][0-9]' | tail -1 | sed -e"s/.*-//")
ifeq "${current_ver}" ""
next_ver ?=
else
next_ver ?= $(shell printf "%.2d" $$((1$(current_ver)-99)))
endif
next := $(draft)-$(next_ver)

.PHONY: latest submit clean

#latest: $(draft).txt $(draft).html

default: $(next).xml $(next).txt $(next).html

idnits: $(next).txt
	$(idnits) $<

clean:
	-rm -f $(draft).txt $(draft).html index.html
	-rm -f $(next).txt $(next).html
	-rm -f $(draft)-[0-9][0-9].xml
ifeq (md,$(draft_type))
	-rm -f $(draft).xml
endif
ifeq (org,$(draft_type))
	-rm -f $(draft).xml
endif
	-rm -rf ../bin

$(next).xml: $(draft).xml ../src/yang/ietf-diffserv.yang ../src/yang/ietf-qos-action.yang ../src/yang/ietf-queue-policy.yang ../src/yang/ietf-scheduler-policy.yang ../src/yang/ietf-traffic-policy.yang ../src/yang/ietf-qos-oper.yang ../src/yang/iana-qos-types.yang
	-mkdir -p ../bin
	sed -e"s/$(basename $<)-latest/$(basename $@)/" -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" $< > $@
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/ietf-diffserv.yang > ../bin/ietf-diffserv\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/ietf-qos-action.yang > ../bin/ietf-qos-action\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/ietf-traffic-policy.yang > ../bin/ietf-traffic-policy\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/ietf-queue-policy.yang > ../bin/ietf-queue-policy\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/ietf-scheduler-policy.yang > ../bin/ietf-scheduler-policy\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/ietf-qos-oper.yang > ../bin/ietf-qos-oper\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/iana-qos-types.yang > ../bin/iana-qos-types\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/example-compa-diffserv.yang > ../bin/example-compa-diffserv\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/example-compb-diffserv-filter-policy.yang > ../bin/example-compb-diffserv-filter-policy\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/example-compb-queue.yang > ../bin/example-compb-queue\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/example-compb-scheduler-policy.yang > ../bin/example-compb-scheduler-policy\@$(shell date +%Y-%m-%d).yang
	sed -e"s/YYYY-MM-DD/$(shell date +%Y-%m-%d)/" ../src/yang/example-compc-qos-policy.yang > ../bin/example-compc-qos-policy\@$(shell date +%Y-%m-%d).yang

	cd ../src; ./validate-and-gen-trees.sh; cd ..;
	../src/insert-figures.sh $@ > tmp; mv tmp $@

.INTERMEDIATE: $(draft).xml
%.xml: %.md
	$(kramdown-rfc2629) $< > $@

%.xml: %.org
	$(oxtradoc) -m outline-to-xml -n "$@" $< > $@

%.txt: %.xml
	$(xml2rfc) $< -o $@ --text
	$(idnits) $@

ifeq "$(shell uname -s 2>/dev/null)" "Darwin"
sed_i := sed -i ''
else
sed_i := sed -i
endif

%.html: %.xml
	$(xml2rfc) $< -o $@ --html
	$(sed_i) -f ../src/addstyle.sed $@


### Below this deals with updating gh-pages

GHPAGES_TMP := /tmp/ghpages$(shell echo $$$$)
.TRANSIENT: $(GHPAGES_TMP)
ifeq (,$(TRAVIS_COMMIT))
GIT_ORIG := $(shell git branch | grep '*' | cut -c 3-)
else
GIT_ORIG := $(TRAVIS_COMMIT)
endif

# Only run upload if we are local or on the master branch
IS_LOCAL := $(if $(TRAVIS),,true)
ifeq (master,$(TRAVIS_BRANCH))
IS_MASTER := $(findstring false,$(TRAVIS_PULL_REQUEST))
else
IS_MASTER :=
endif

index.html: $(draft).html
	cp $< $@

ghpages: index.html $(draft).txt
ifneq (,$(or $(IS_LOCAL),$(IS_MASTER)))
	mkdir $(GHPAGES_TMP)
	cp -f $^ $(GHPAGES_TMP)
	git clean -qfdX
ifeq (true,$(TRAVIS))
	git config user.email "ci-bot@example.com"
	git config user.name "Travis CI Bot"
	git checkout -q --orphan gh-pages
	git rm -qr --cached .
	git clean -qfd
	git pull -qf origin gh-pages --depth=5
else
	git checkout gh-pages
	git pull
endif
	mv -f $(GHPAGES_TMP)/* $(CURDIR)
	git add $^
	if test `git status -s | wc -l` -gt 0; then git commit -m "Script updating gh-pages."; fi
ifneq (,$(GH_TOKEN))
	@echo git push https://github.com/$(TRAVIS_REPO_SLUG).git gh-pages
	@git push https://$(GH_TOKEN)@github.com/$(TRAVIS_REPO_SLUG).git gh-pages
endif
	-git checkout -qf "$(GIT_ORIG)"
	-rm -rf $(GHPAGES_TMP)
endif
