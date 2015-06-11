# Scrabble Stems

## About

Best of Ruby Quiz, Chapter 5

In Scrabble parlance, a bingo is a play where one gets rid of all seven letters. A bingo stem is a set of six letters that combine with another letter of the alphabet to make a seven-letter word. Some six-letter stems have more possible combinations than others. For instance, one of the more prolific stems, SATIRE, combines with twenty letters: A, B, C, D, E,F,G,H,I,K,L,M,N,O,P,R,S,T,V,and W to form words such as ASTERIA, BAITERS, RACIEST, and so on.

Write a program that, given a word list and a cutoff `n`, finds all six-letter stems that combine with `n` or more distinct letters, sorted by greatest number of combinations to least.

If you need a word list to help in developing a solution, you can find [Spell Checking Oriented Word Lists (SCOWL)](http://wordlist.aspell.net/) online.

## Requirements

Ruby 2.2.2

## Notes

wordlist.txt was downloaded from [http://app.aspell.net/create](http://app.aspell.net/create), with all words less than 6 characters and words containing apostrophes deleted.

- `wordlist.txt` is the full list.
- `wordlist2.txt` is a shorter list (moderate setting).
- `wordlist3.txt` is a sample of about half of wordlist2.txt.

Regex to find lines containing apostrophes: `\b\w+'\w+\n`

## Usage

run `bundle install`
run `./stems.rb -n 5 wordlist.txt`

## Understanding the Question

We need to loop through all the six-letter words. For each word, find all seven letter words that have one different letter. In other words, find all seven letter words that contain all the same six letters. 

Then, sort the list of seven letter words by the distinct letter. We could store the words in a hash `{"A": ["word1", "word2", ...], "B": ["word100", "word101", ...]}`. Then, we use Enumerable's :sort_by

    letters.sort_by{ |letter, arr| array.size }.reverse

We need `.reverse` because sort_by is in ascending order. 

**The cutoff**

Is there a way to determine which words have less than *n* distinct letters to combine with? 

The brute force method would be to perform the above, and then remove the words for which there are less than *n* keys. That's potentially many wasted loops. 

It appears that there isn't an easy way to know which words have less than *n*. There's a fast way to skip if it were **more than** *n*; just jump to the next word once the quota of letters has been hit. 

## Points of Interest

- cannot simply use Array's A-B (`:-` method) to determine if a stem is a subset of a seven. 
- implemented [SO Answer](http://stackoverflow.com/a/11354782/575388) in `Seven#subset?`
- a [more relevant](http://stackoverflow.com/questions/3852755/ruby-array-subtraction-without-removing-items-more-than-once) SO Question
- implemented the ruby-prgressbar gem for nicer output, since it's a long running process.

# Review

The program works, but it seems very inefficient, taking ~ 5 min to run. 

[Sample run](http://youtu.be/xq6ofMv-jss)

**After referring to the answer**, it seems my understanding was different from the author's. Apparently the stems don't need to be real words. Which makes sense, because the 6 letter stems are the letters in your hand. I had the impression that the 6 letters were on the board and you had one letter to match to them. 

**Correct approach** is to loop through all 7 letter words, and find the unique stems for each word by removing each letter. i.e. ANGRIER => AEGINRR => hash['AEGINR']['A'] = true

    {
      "AEGINR": {
        "A": true,
        "E": true,
        "G": true,
        # ... potentially up to 26 combinations
      }
    }

## License

This code is released under the [MIT License](http://www.opensource.org/licenses/MIT)


