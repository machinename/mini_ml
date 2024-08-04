import 'package:flutter/material.dart';
import 'package:mini_ml/utils/constants.dart';

class Workflow extends StatelessWidget {
  const Workflow({super.key});

  _back(BuildContext context) {
    Navigator.pop(context);
  }

  Widget _buildBody(BuildContext context) {
    final horizontalPadding = Constants.getPaddingHorizontal(context);
    final verticalPadding = Constants.getPaddingVertical(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: ListView(
        children: [
          const Text(
            'What is machine Workflowing?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'The fundamental idea of machine Workflowing is to use data from past observations to predict unknown outcomes or values.',
          ),
          SizedBox(height: horizontalPadding * 2),
          const Text(
            'Types of machine Workflowing',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: horizontalPadding),
          const Text(
            'Supervised machine Workflowing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Supervised machine Workflowing is a general term for machine Workflowing algorithms in which the training data includes both feature values and known label values. '
            'Supervised machine Workflowing is used to train models by determining a relationship between the features and labels in past observations, so that unknown labels can be predicted for features in future cases.',
          ),
          SizedBox(height: horizontalPadding),
          const Text(
            'Regression',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Regression is a form of supervised machine Workflowing in which the label predicted by the model is a numeric value. For example:',
          ),
          const Text(
            '• The number of ice creams sold on a given day, based on the temperature, rainfall, and windspeed.\n'
            '• The selling price of a property based on its size in square feet, the number of bedrooms it contains, and socio-economic metrics for its location.\n'
            '• The fuel efficiency (in miles-per-gallon) of a car based on its engine size, weight, width, height, and length.',
          ),
          SizedBox(height: horizontalPadding),
          const Text(
            'Classification',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Classification is a form of supervised machine Workflowing in which the label represents a categorization, or class. There are two common classification scenarios.',
          ),
          SizedBox(height: horizontalPadding),
          const Text(
            'Binary classification',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'In binary classification, the label determines whether the observed item is (or isn’t) an instance of a specific class. For example:\n'
            '• Whether a patient is at risk for diabetes based on clinical metrics like weight, age, blood glucose level, and so on.\n'
            '• Whether a bank customer will default on a loan based on income, credit history, age, and other factors.\n'
            '• Whether a mailing list customer will respond positively to a marketing offer based on demographic attributes and past purchases.',
          ),
          SizedBox(height: horizontalPadding),
          const Text(
            'Multiclass classification',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Multiclass classification extends binary classification to predict a label that represents one of multiple possible classes. For example:\n'
            '• The species of a penguin (Adelie, Gentoo, or Chinstrap) based on its physical measurements.\n'
            '• The genre of a movie (comedy, horror, romance, adventure, or science fiction) based on its cast, director, and budget.\n'
            'In most scenarios that involve a known set of multiple classes, multiclass classification is used to predict mutually exclusive labels. For example, a penguin can’t be both a Gentoo and an Adelie. However, there are also some algorithms that you can use to train multilabel classification models, in which there may be more than one valid label for a single observation. For example, a movie could potentially be categorized as both science fiction and comedy.',
          ),
          SizedBox(height: horizontalPadding),
          const Text(
            'Unsupervised machine Workflowing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Unsupervised machine Workflowing involves training models using data that consists only of feature values without any known labels. Unsupervised machine Workflowing algorithms determine relationships between the features of the observations in the training data.',
          ),
          SizedBox(height: horizontalPadding),
          const Text(
            'Clustering',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'The most common form of unsupervised machine Workflowing is clustering. A clustering algorithm identifies similarities between observations based on their features and groups them into discrete clusters. For example:\n'
            '• Group similar flowers based on their size, number of leaves, and number of petals.\n'
            '• Identify groups of similar customers based on demographic attributes and purchasing behavior.\n'
            'In some ways, clustering is similar to multiclass classification; in that it categorizes observations into discrete groups. The difference is that when using classification, you already know the classes to which the observations in the training data belong; so the algorithm works by determining the relationship between the features and the known classification label. In clustering, there’s no previously known cluster label and the algorithm groups the data observations based purely on similarity of features.\n'
            'In some cases, clustering is used to determine the set of classes that exist before training a classification model. For example, you might use clustering to segment your customers into groups, and then analyze those groups to identify and categorize different classes of customer (high value - low volume, frequent small purchaser, and so on). You could then use your categorizations to label the observations in your clustering results and use the labeled data to train a classification model that predicts to which customer category a new customer might belong.',
          ),
        ],
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    // String? displayName = appProvider.auth.currentUser?.displayName;
    return AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp),
            onPressed: () {
              _back(context);
            }),
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text('Workflow'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }
}
