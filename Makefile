# this generates all the pages
# for testing in my revamped version
# of konqueror, booya!
page-gen:
	ruby strip-xss-websites.rb
	ruby delimiter-add.rb
