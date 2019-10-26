

# OJS Toolbox

Given a Open Journal System (OJS) root URL and an authorization token, cache all JSON files associated with the given OJS title, and optionally output rudimentary bibliographics in the form of a tab-separated value (TSV) stream.

The OJS is a journal publishing system. [1] Is supports a REST-ful API allowing the developer to read &amp; write to the System's underlying database. [2] This hack -- the OJS Toolbox -- merely caches &amp; reads the metadata associated with the published issues of a given journal title.

The Toolbox is written in Bash. To cache the metadata, you will need to have additional software as part of your file system: curl and jq. [3, 4] Curl is used to interact with the API. Jq is used to read &amp; parse the resulting JSON streams. When &amp; if you want to transform the cached JSON files into rudimentary bibliographics, then you will also need to install GNU Parallel, a tool which makes parallel processing trivial. [5]

Besides the software, you will need three pieces of information. The first is the root URL of the OJS system/title you wish to use. This value will probably look something like this --&gt; https://example.com/index.php/foobar  Ask the OJS systems administrator regarding details. The second piece of information is an authorization token. If a "api secret" value has been created by the local OJS systems administrator, then each person with an OJS account ought to have been granted a token. Again, ask the OJS systems administrator for details. The third piece of information is the name of a directory where your metadata will be cached. For the sake of an example, assume the necessary values are:

   1. root URL - https://example.com/index.php/foobar
   2. token - xyzzy
   3. directory - foobar

Once you have gotten this far, you can cache the totality of the issue metadata:

    $ ./bin/harvest.sh https://example.com/index.php/foo xyzzy bar
   
More specifically, harvest.sh will create a directory called bar. It will then determine how many issues exist in the title foo. It will then harvest sets of issue data, parse each set into individual issue files, and save the result as JSON files in the bar directory. You now have a "database" containing all the bibliographic information of a given title

For my purposes, I need a TSV file with four columns: 1) author, 2) title, 3) date, and 4) url. Such is the purpose of issues2tsv.sh and issue2tsv.sh. The first script, issues2tsv.sh, takes a directory as input. It then outputs simple header, finds all the JSON files in the given directory, and passed them along (in arallel) to issue2tsv.sh which does the actual work. Thus, to create my TSV file, I can submit a command like this:

    $ ./bin/issues2tsv.sh bar > ./bar.tsv
    
The result will look something like this:

| author    | title        | date       | url                                                          |
|-----------|--------------|------------|--------------------------------------------------------------|
| Kilgour   | The Catalog  | 1972-09-01 | https://example.com/index.php/foo/article/download/5738/5119 |
| McGee     | Two Designs  | 1972-09-01 | https://example.com/index.php/foo/article/download/5739/5120 |
| Saracevic | Book Reviews | 1972-09-01 | https://example.com/index.php/foo/article/download/5740/5121 |




## Links

[1] OJS - https://pkp.sfu.ca/ojs/  
[2] OJS API - https://docs.pkp.sfu.ca/dev/api/ojs/3.1  
[3] curl - https://curl.haxx.se  
[4] jq - https://stedolan.github.io/jq/  
[5] GNU Parallel - https://www.gnu.org/software/parallel/


--- 
Eric Lease Morgan &lt;emorgan@nd.edu&gt;  
October 26, 2019
