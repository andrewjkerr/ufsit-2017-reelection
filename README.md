# ufsit-2017-reelections

In an effort of transparency, this repository contains literally everything from the UFSIT 2017 re-election. This README outlines the process (in both a tl;dr and a detailed format) as well as the included files in the repository.

## Winners

- President: Terry Thibault
- Vice President: Elan Rasabi
- Treasurer: Spencer Fleming
- Secretary: Scott Miller

Congrats to the new board! I look forward to yet another bright year of SIT! :tada:

## What Happened? (tl;dr)

There was a Google form that ranked each candidate for each position from "Best candidate" to "#{nth} Best Candidate". The voting ran from Monday night to Friday night at 23:59 EST.

Each voter was given a "unique identifier" in which to submit along with their ballot to verify that each voter only voted once. If a voter did vote twice, I emailed them to confirm which ballot they wanted to submit. You can see the timestamps at which each unique identifier voted in `voting-timestamps.csv`.

All email templates for (1) sending out the ballot, (2) following up with reminders, and (3) asking which ballot is valid in the `emails` directory.

After the voting ended, I double checked each candidate to make sure that they adhered to the election standards as well as spot checked the membership of each voter.

I then ran the `ranked-voting.rb` script included in this repository over the results of the votes to determine the winners.

All election materials are included in this repository.

## The (Very Detailed) Process

### Membership List

The membership list was generated by the current board and given to me a few days before I sent out the ballot. From that, I created a spreadsheet that I populated with the following information:

- Name
- Unique Identifier (used for the ballot, generated with `generate-random-ids.sh`)
- Email Sent?
- Voted?
- Verified last ballot cast was correct?

#### Adding Members to the Voting List

There was one member who could not be given active membership based solely off of the sign-in sheets. However, three members of the current board verified their membership and they were given access to the ballot.

### The Ballot

The ballot was given to me at the same time as the membership list. I copied the ballot from an officer's Google account to my own personal one.

The email for sending out the ballot is available in `emails/email-script.txt`.

### Voting

As votes were cast, I updated the spreadsheet earlier to keep track of who voted and who did not.

The timestamps + unique identifiers of all of the voters are available in the `voting-timestamps.csv` file.

All of the votes for each position have been scrubbed of the unique identifier and randomized and are available in this repository in CSV form.

### Reminders

I sent out two reminders; one mid-week and one on Friday afternoon. Both reminders went out to those who did not vote at that point.

The emails for sending out the reminders are available in `emails/reminder-email-n.txt`.

### Auditing of Election Standards

When the ballots were cast, I conducted an audit of the election to confirm that the election was being conducted to the standards in the constitution.

#### New Constitution Amendments on April 20th

There were amendments to the constitution voted upon by the general membership on April 20th that were intended to affect the re-election. However, according to Article XIV, Section B, since SG did not ratify the constitutional amendments, this re-election could not be run under the new amendments.

The full text of Article XIV, Section B is below:
> Amendments shall be ratified by a two-thirds vote of active student members present at the meeting. Amendment votes must be announced at least one week prior. The revised Constitution will not take affect until it has been approved by the University of Florida.

#### Verifying Membership Requirements for Potential Officers

Since the re-election could not use the new constitution, Article VI, Section B was still in affect. Article VI, Section B states:
> Individuals holding office must be considered active student members of the Student Information Security Team, as per Article V and Article XIV, at least two weeks prior to their election.

Because one candidate could not have their membership verified before the two weeks cutoff, they were disqualified.

### Producing the Results

#### Candidates

Below is the list of candidates along with their corresponding indices for each round. These indices are NOT their rank, but are just the way the CSV spreadsheet ordered them.

##### President

1. Terry Thibault
2. Elan Rasabi

##### Vice President

1. Terry Thibault
2. Elan Rasabi
3. Spencer Fleming
4. Scott Miller

##### Treasurer


1. Terry Thibault
2. Elan Rasabi
3. Herbert Coard
4. Spencer Fleming

##### Secretary

1. Terry Thibault
2. Elan Rasabi
3. Juan Jauegui (Disqualified due to Article VI, Section B)
4. Scott Miller
5. Spencer Fleming

#### Producing the CSV files

In order to determine the winners, I downloaded each race as a separate CSV file. I manually edited each CSV file to add quotation marks to make it a valid CSV file.

Then, I ran each file through GNU sort (`gsort -R file.csv > randomized.csv` on macOS; `sort -R file.csv > randomized.csv` on UNIX) to produce the files that are in this repository. I verified that the results were the same before and after the conversion which led me to believe that randomizing the files did not change anything.

#### Script Bug Fix

No code is ever solid the first time around! Through testing the CSV files, I discovered a bug in my `ranked-voting.rb` script. The diff is shown below:

```diff
...
# Track number of rounds.
current_round_number = 0

+ # Track eliminated candidates
+ eliminated = []

while true do
...

...
  # Count up the votes of this round!
  data.each do |ranking|
+    while eliminated.include?(ranking.first)
+      ranking.shift
+    end

    vote = ranking.first
    current_round[vote] ||= 0
    current_round[vote] += 1
  end
```

I'm happy to say that the bug did not affect results (I will explain why below).

#### Running the Damn Thing

##### President

No modifications needed to be made for this round of results.

I ran the damn thing:

```
➜  ufsit-election git:(master) ✗ ruby ranked-voting.rb president.csv
Current round: 1
1 has 0.5405405405405406 of the vote.
1 has won with 0.5405405405405406 of the vote!
```

Candidate 1 (Terry Thibault) has won the presidency with 54% of the vote. Congrats Terry! :tada:

##### Vice-President

I added Terry's index to the `candidates_already_won` array:

```diff
# Did a current candidate already win another position?
- candidates_already_won = []
+ candidates_already_won = [1]
```

And then ran the damn thing:

```
➜  ufsit-election git:(master) ✗ ruby ranked-voting.rb vice-president.csv
Current round: 1
2 has 0.7837837837837838 of the vote.
2 has won with 0.7837837837837838 of the vote!
```

Candidate 2 (Elan Rasabi) has won the vice presidency with 78% of the (ranked) vote. Congrats Elan! :tada:

##### Treasurer

I added Elan's index to the `candidates_already_won` array:

```diff
# Did a current candidate already win another position?
- candidates_already_won = [1]
+ candidates_already_won = [1, 2]
```

And then ran the damn thing:

```
➜  ufsit-election git:(master) ✗ ruby ranked-voting.rb treasurer.csv
Current round: 1
4 has 0.7027027027027027 of the vote.
4 has won with 0.7027027027027027 of the vote!
```

Candidate 4 (Spencer Fleming) has won the treasurer position with 70% of the (ranked) vote. Congrats Spencer! :tada:

##### Secretary

I added Spencer's index to the `candidates_already_won` array. I also added the DQ'd candidate's index to the same array to exclude votes for them:

```diff
# Did a current candidate already win another position?
- candidates_already_won = [1, 2]
+ candidates_already_won = [1, 2, 3, 5]
```

And then ran the damn thing:

```
➜  ufsit-election git:(master) ✗ ruby ranked-voting.rb secretary.csv
Current round: 1
4 has 1.0 of the vote.
4 has won with 1.0 of the vote!
```

Candidate 4 (Scott Miller) has won the secretary position with 100% of the (very ranked) vote. Congrats Scott! :tada:

## Reproduce Results

If you want to calculate the results at home, you'll need to:

1. Clone this repository
2. Run `ruby ranked-voting.rb president.csv`
3. Look at the results
4. Add the winner's _next position_ index to the `candidates_already_won` array
5. Keep running it for the other positions :)

Basically, if you follow the steps outlined above you should be able to reproduce the same results as I did.

## Lessons Learned

There are plenty of lessons to be learned from the whole election process, but here are some things that came up during the re-election that I wish I had done better:

1. Allow candidates to post "speeches" and have a publicly available repository of speeches (GitHub, maybe?).
2. Audit constitution + candidates _before_ the election.
3. Manually adding "VOTED?" booleans to the membership spreadsheet was somewhat tedious. Scripts could have been written. Google Apps has a (surprisingly) robust scripting API.
4. Manually sending out emails was super tedious. Scripts could have also been written. :)
5. Releasing election results on my birthday. Seriously. I should be partying by now...

## Questions?

If you have any questions/comments, please feel free to contact me! If you're reading this, you either (1) know how to contact me or (2) know where to find my contact information (hint: it's on GitHub).
