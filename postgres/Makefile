all:
	cp config/postgresql.base.conf /Volumes/HDD/var/postgres/postgresql.base.conf
	bash $(CURDIR)/scripts/initdb.sh
	bash $(CURDIR)/scripts/conf.sh
	bash $(CURDIR)/scripts/psql.sh
	python3 $(CURDIR)/scripts/pgadmin.py
