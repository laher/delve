.DEFAULT_GOAL=test
UNAME = $(shell uname)
PREFIX=github.com/derekparker/delve

ifndef $(RUN)
	RUN = ".*"
endif

build:
	go build github.com/derekparker/delve/cmd/dlv
ifeq "$(UNAME)" "Darwin"
ifeq "$(CERT)" ""
	$(error You must provide a CERT env var)
endif
	codesign -s $(CERT) ./dlv
endif

install:
	go install github.com/derekparker/delve/cmd/dlv
ifeq "$(UNAME)" "Darwin"
ifeq "$(CERT)" ""
	$(error You must provide a CERT env var)
endif
	codesign -s $(CERT) $(GOPATH)/bin/dlv
endif

test:
ifeq "$(UNAME)" "Darwin"
ifeq "$(CERT)" ""
	$(error You must provide a CERT env var)
endif
	go test $(PREFIX)/terminal $(PREFIX)/dwarf/frame $(PREFIX)/dwarf/op $(PREFIX)/dwarf/util $(PREFIX)/source $(PREFIX)/dwarf/line
	cd proc && go test -c $(PREFIX)/proc && codesign -s $(CERT) ./proc.test && ./proc.test $(TESTFLAGS) && rm ./proc.test && cd ..
	cd service/rest && go test -c $(PREFIX)/service/rest && codesign -s $(CERT) ./rest.test && ./rest.test $(TESTFLAGS) && rm ./rest.test && cd ../..
else
	go test -v ./...
endif

test-proc-run:
ifeq "$(UNAME)" "Darwin"
ifeq "$(CERT)" ""
	$(error You must provide a CERT env var)
endif
	cd proc && go test -c $(PREFIX)/proc && codesign -s $(CERT) ./proc.test && ./proc.test -test.run $(RUN) && rm ./proc.test && cd ..
else
	go test $(PREFIX) -run $(RUN)
endif

test-integration-run:
ifeq "$(UNAME)" "Darwin"
ifeq "$(CERT)" ""
	$(error You must provide a CERT env var)
endif
	cd service/rest && go test -c $(PREFIX)/service/rest && codesign -s $(CERT) ./rest.test && ./rest.test -test.run $(RUN) && rm ./rest.test && cd ../..
else
	go test $(PREFIX)/service/rest -run $(RUN)
endif
