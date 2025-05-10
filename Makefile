VERSION := 1.1.2
PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib/patchouli
CONFDIR := $(PREFIX)/etc/patchouli

.PHONY: install uninstall clean

install:
	@echo "Installing Patchouli v$(VERSION)"
	
	# Create directories
	install -d $(BINDIR)
	install -d $(LIBDIR)/lib/core
	install -d $(LIBDIR)/lib/commands
	install -d $(LIBDIR)/lib/help
	install -d $(LIBDIR)/lib/vcs
	install -d $(CONFDIR)
	
	# Install main executable
	install -m 755 bin/patchouli.sh $(BINDIR)/patchouli
	
	# Install core modules
	install -m 644 lib/core/*.sh $(LIBDIR)/lib/core/
	
	# Install command modules
	install -m 644 lib/commands/*.sh $(LIBDIR)/lib/commands/
	
	# Install help modules
	install -m 644 lib/help/*.sh $(LIBDIR)/lib/help/
	
	# Install VCS modules
	install -m 644 lib/vcs/*.sh $(LIBDIR)/lib/vcs/
	
	# Install configuration files
	install -m 644 config/*.conf $(CONFDIR)/
	
	@echo "Installation complete. Run 'patchouli help' for usage."

uninstall:
	@echo "Uninstalling Patchouli"
	rm -f $(BINDIR)/patchouli
	rm -rf $(LIBDIR)
	rm -rf $(CONFDIR)
	@echo "Uninstallation complete."

clean:
	@echo "Cleaning up"
	rm -f *.patch
	@echo "Clean complete"
