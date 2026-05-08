
import pandas as pd
women_results = pd.read_csv('women_results.csv', index_col = 0, parse_dates = ['date'])
men_results = pd.read_csv('men_results.csv', index_col = 0, parse_dates = ['date'])

women_fwc = women_results[(women_results['tournament'] == 'FIFA World Cup') & (women_results['date'] > '2002-01-01')]
men_fwc = men_results[(men_results['tournament'] == 'FIFA World Cup') & (men_results['date'] > pd.to_datetime('2002-01-01'))]

women_fwc.head()

# total goals in a match
men_fwc['total_goals'] = men_fwc['home_score'] + men_fwc['away_score']
women_fwc['total_goals'] = women_fwc['home_score'] + women_fwc['away_score']
men_mean = men_fwc['total_goals'].mean()
women_mean = women_fwc['total_goals'].mean()

#size of samples
n_m = len(men_fwc)
n_w = len(women_fwc)

# standar deviations of the samples
men_std = men_fwc['total_goals'].std()
women_std = women_fwc['total_goals'].std()

df = n_m + n_w - 2

print(men_mean, women_mean)
print(n_m,n_w)
print(men_std, women_std)
print(df)

"""
Choosing the right test
Because there are two independent groups, men's and women's, this scenario requires an unpaired two-sample test.
An unpaired t-test and a Wilcoxon-Mann-Whitney test are the two most commmon two-sample tests, where the Wilcoxon-Mann-Whitney test is a non-parametric version of the unpaired t-test.
To determine if a parametric or non-parametric test is appropriate, we'll need to verify the underlying assumptions of parametric tests, including checking the sample size in each group and the normality of each distribution.
Determining if the data is normally distributed
Plotting a histogram displaying the distribution of the number of goals scored in men's and women's matches will give us an idea about whether the dataset is normally distributed or not.
If the normality is unclear from the plot, we can run a test of normality, such as a Kolmogorov–Smirnov test or the Shapiro–Wilk test.
"""
# Checkin the normality of the data
import matplotlib.pyplot as plt

plt.figure(figsize=(8,5))

plt.hist(
    men_fwc['total_goals'],
    bins=15,
    alpha=0.6,
    label='Men'
)

plt.hist(
    women_fwc['total_goals'],
    bins=15,
    alpha=0.6,
    label='Women'
)

plt.xlabel('Total Goals')
plt.ylabel('Frequency')
plt.title('Distribution of Total Goals in FIFA Matches')

plt.legend()

plt.show()

# Performing the wilcoxon-mann-whityney test
import pingouin
test = pingouin.mwu(x = women_fwc['total_goals'], y = men_fwc['total_goals'], alternative = 'greater')

alpha = 0.1
p_value = test['p-val'][0]

test_res = p_value <= alpha

result = ''
if test_res == True:
    result = 'reject'
else:
    result = 'fail to reject'
result_dict = {"p_val": p_value, "result": result}
result_dict





"""
In case if the test is parametric we can use the unpaired two sample ttest

# unpaired two-sample t-test
import numpy as np

alpha = 0.1
numerator = women_mean - men_mean
denominator = np.sqrt(men_std **2 /n_m + women_std**2/n_w)
t_stat = numerator/denominator
print(t_stat)

from scipy.stats import t
p_value = 1 - t.cdf(t_stat, df = df)

test_res = p_value <= alpha
result = ''
if test_res == True:
    result = 'reject'
else:
    result = 'fail to reject'

result_dict = {"p_val":p_value, "result":result}
p_value
result_dict
"""
