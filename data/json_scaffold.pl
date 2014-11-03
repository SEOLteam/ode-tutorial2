 #!/usr/local/bin/perl

$top_limit = 6;
for $i (1 .. $top_limit) {
    print "{\n";
    print "\t\"unit\": \"Unit $i\",\n";
    print "\t\"topic\": \"Topic $i\",\n";

    # Expand into array for future
    print "\t\"p1\": \"Sentences la la la\",\n";
    print "\t\"p2\": \"Sentences la la la\",\n";
    print "\t\"p3\": \"Sentences la la la\",\n";

    # Expand into array for future
    print "\t\"mc\": {\n";
    print "\t\t\"q\": \"What up doc?\",\n";
    print "\t\t\"ans\": \"Correct Answer\",\n";
    print "\t\t\"a\": \"Answer\",\n";
    print "\t\t\"b\": \"Answer\",\n";
    print "\t\t\"c\": \"Answer\",\n";
    print "\t\t\"d\": \"Answer\",\n";
    print "\t\t\"e\": \"Answer\"\n";
    print "\t}\n";

    print "},\n";
}