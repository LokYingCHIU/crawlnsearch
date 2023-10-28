# web-based-search-engine

To crawl the pages and search: 
1. Download this repository, unzip it, and put it under "webapps" of tomcat.
2. Run %CATALINA_HOME%\bin\startup.bat in cmd.
3. Go to http://localhost:8080/search-engine/crawl.html, click the button to perform crawling.
4. Go to http://localhost:8080/search-engine/form.html to submit a user input.

# web-based-search-engine

To crawl the pages and search: 
1. Download this repository, unzip it, and put it under "webapps" of tomcat.
2. Run %CATALINA_HOME%\bin\startup.bat in cmd.
3. Go to http://localhost:8080/search-engine/crawl.html, click the button to perform crawling.
4. Go to http://localhost:8080/search-engine/form.html to submit a user input.


### Overall design of the system
The crawler crawls information of webpages recursively using a breadth-first strategy. It stores the 
information including inverted index, forward index, parent and child links, title, last modified date, size, 
etc. into the corresponding database files. 

After crawling the pages, a user can submit a query to the system simply through the user interface. The 
system then ranks the pages stored in the database by their similarity to the query, it returns the ranked 
similar pages and shows their information to the user.

To clear the database files, the user needs to delete them manually.

### File structures
_crawl_pack_ contains classes that help performing crawling.
\
_search_pack_ contains classes that help performing searching.
\
_stopAndStem_ contains classes that help performing stopping and stemming.

_lib_ contains the jar files that this program depends on.

_crawl.html_ is used to crawl the pages by a click on the button.
\
_form.html_ is used to submit query and get the related pages from the crawled documents.

#### Database Schema: 
| Database file | Key | Value | Description|
| -------- | -------- | -------- |-------- |
| forwardIndex  | doc_id  | Posting(word_id, freq)  | Use a document’s ID as the key to get the words appear in this document and their frequencies.  |
| invertedIndex (for page body)  | word_id  | Posting(doc_id, freq)  | Use a word’s ID as the key to get the webpages that contain this word in their body and its frequencies.  |
| titleInvertedIndex  | word_id  | Posting(doc_id, freq)  | Use the word’s ID as the key to get the webpages that contain this word in their title and its frequencies.  |
| Page  | pageId  | PageInfo  | Use a page’s ID as the key to get the info (including title, last modified date, size, body max tf, and title max tf) of the page.  |
| pageID_url  | page_id  | url  | Use a page’s ID as the key to get the corresponding url.  |
| wordID_word  | word_id  | word_df  | Use a word’s ID as the key to get the corresponding word and its df.  |
| childToParent  | c_url_id  | parentSet  | Use the children page’s id to get its set of parent pages.  |
| parentToChild  | p_url_id  | childSet  | Use the parent page id to get its set of children pages.  |


### Algorithms
1. To deal with pages that redirect the user to another page:
 
    When performing recursive crawling, before crawling each page, the crawler checks if it redirects the 
user to another page. If the crawler sees a webpage (A) that redirects the user to another page (B), it 
crawls page B and marks both pages as expanded, so that neither page A nor page B will be crawled in 
the same run. Also, pages that are permanently moved to another URL will not be crawled into the 
database.
2. To perform crawling recursively:

    These are the tools used to help perform recursion and their data structures and purposes, the pages 
are represented by their ID in the implementation:

    For simplicity, I assume there is not redirection problem for now.

    a. url_q: a first-in-first-out queue that stores the pages that are waiting for being crawled (nodes 
waiting for being expanded).
    
    b. crawled: a set storing the crawled pages (expanded nodes).
    
    c. seen: a set of pages that have been in url_q before or are still in url_q (nodes waiting for being 
expanded + expanded nodes).

    First, the starting page is added into url_q and seen. It is then taken out from url_q, crawled, and added 
to crawled (marked as expanded). Afterward, its children links that are not in seen are added into url_q
and seen.

    The first page in url_q is then crawled and the same actions done to the previous page are repeated on 
this page. The same procedures go on and on until the number of pages is met or there is no more page 
in url_q.

3. To crawl a page: 

    Before crawling a page, it first checks if the page’s information exists in the database.

    a. If it exists, it checks the last modified date of the webpage and compares it with that in the 
database.
    
    (i.) If it is modified after the last crawl, then it crawls the page and updates all the information.
    
    (ii.) Otherwise, it does not continue crawling.

    b. If it does not exist, it crawls the page.
4. To store words from a page: 

    First, it takes all the one-gram tokens excluding stopwords from the page’s words, and performs 
stemming to those one-grams. (Some words become an empty string after stemming, those are also 
excluded.) 

    2-grams are formed from the one-grams without stopping and stemming. It checks if the 2-grams 
contain stopwords or words that become an empty string after stemming. If it does, discard the 2-gram. 

    3-grams are formed in a similar way as 2-grams.
5. To rank the pages: 

    a. Convert the query into 1-grams, 2-grams, and 3-grams, and extract the phrases enclosed by 
quotation marks.

    b. Calculate the cosine similarity between a page and the query: 

        (i.) First, set the similarity score = 0.

        (ii.) Iterate through all the x-grams of the query, if the page contains the x-gram in the body, add the word’s tfidf to the similarity score, if the page contains it in the title, multiply the word’s tfidf by 10 and add the product to the similarity score. Otherwise do nothing. 

        (iii.) Iterate through all the phrases extracted from the query. If the page contains the phrase in its body, add the word’s tfidf to the similarity score. If the page contains it in the title, multiply the word’s tfidf by 10 and add the product to the similarity score. Otherwise do nothing.

        (iv.) TF*IDF score of a term here is calculated as: 
    
            ◼ TF (term frequency, normalized by the max tf in the document)

            ◼ IDF (inverse document frequency): log(1/n), where n is the number of documents that contains the specific term. It was supposed to be log(N/n), where N is the total number of documents, however, since N is a constant number, I ignored it for simplicity.

        (v.) The final score of the page is divided by number of different x-grams of the page*number of different x-grams of the query.

    c. Put the pages into a priority queue when the priorities are the similarity scores of the pages.

### Installation procedure
1. Unzip the project.
2. Put the whole project under “webapps” of tomcat.

### Highlight of features beyond the required specification
1. It deals with the redirection problem to avoid crawling deleted or moved pages, which is unmeaningful.

### Demo
crawled 30 webpages from: http://www.cse.ust.hk

Query: cse department

Result (listing the titles of result pages from the most relevant):

    CSE department of HKUST
    Test page
    PG
    UG
    ...

Query: “Hong Kong” UG program in “Computer Science”

Result (listing the titles of result pages from the most relevant):

    UG
    PG
    CSE department of HKUST
    ...

### Conclusion
If I were to re-implement the system, I would store the positions of words in the inverted index instead of 
the frequencies of x-grams. This approach would avoid the issue of storing many meaningless x-grams, 
resulting in a table with numerous unnecessary entries. Furthermore, given that users are expected to 
submit queries with phrases enclosed in quotation marks, storing positions of words would align better 
with the design. The current design, which stores frequencies of x-grams, works without quotation marks 
because it uses the phrases in the inverted index as a key.

Additionally, to simplify the code and make it easier to manage, I would create a super class for the classes 
that perform similar tasks in managing the database files. This would lead to cleaner code and more 
efficient management.

Overall, this project was a fun one that helps me with practicing designing the system, coding in Java, and understanding how a search engine works in general. 
