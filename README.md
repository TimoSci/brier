# Brier

A simple command line tool keeps track of your **brier score** as a developer.

## Purpose & Motivation

By measuring and tracking your ability to estimate the likelihood of bugs occurring in your code, you can
consciously improve that ability.

Hopefully, as you get better at predicting bugs, you are less likely to write them in the first place. As "unknown unknowns" become "known unknowns" you  become a more productive developer.

## Usage

1. Every time you are about to do a unit test, enter a probability between 0.0 and 1.0. This is your probability estimate for a test **passing**.

`brier 0.8`

2. After you run the test enter the result.

`brier pass`
`brier fail`

3. To display your global score and moving average

`brier score`

To track how you are trending

`brier trend`

To delete your score and start afresh

`brier reset`


## Tips

* The lower the score, the better. The whole point of the exercise is to decrease your score over time.

* Don't just pick arbitrary probabilities. Try to intuit them. Try to *explain* them. Initially this will be hard. A good place to start: Imagine that you have to bet $10 of real money on the outcome of your unit test. If the test passes you win $10/(probability of passing). If your test fails you lose $10. Pick the *highest* probability where you still feel comfortable making that bet.  

* **50:50** is often a tempting answer but it's lazy. In the real world, it is rare for events to have a probability of *exactly* 50%. If you think a little bit deeper about the problem, you can usually do better than just saying 50:50.

* As you gain experience, build heuristics in your head for **prior probabilities** of bugs for different classes of code. Then, apply **Bayes' Rule** to the individual case to refine your probability estimate.

* Sometimes a good way to estimate probabilities is **counterfactual thinking**. Do a thought experiment where you imagine a large number of parallel universes. They are deterministic and almost identical to our universe, except they differ by some small detail (eg. in one universe you made a typo in your function declaration and in another you didn't). Then imagine the universes evolving over time. Then ask, how many universes have outcome X, how many have outcome Y?

* Alternatively, a **Frequentist** philosophy can be applied. Use the historic average of unit test pass rate as a **prior probability** for a first estimate. get the pass rate in current context (path) by typing `brier stats` 

* As you gain confidence, make your predictions more precise. Start with single digits after the comma and then move on to double digits.

* Only make small changes to your code. Change one specific aspect (ideally, one line of code). Then predict the test outcome. Then test. Rinse and repeat Don't try to make several unrealted changes and then try to estimate a prediction. This will make it harder to reason about your estimate. 
---

## References

* [Brier Score](https://en.wikipedia.org/wiki/Brier_score)

* [Bayes' theorem](https://en.wikipedia.org/wiki/Bayes%27_theorem)

## Further Reading

* [Less Wrong](https://www.lesswrong.com/)

* [Superforecasters](https://www.google.com/search?q=ISBN:0771070543)
