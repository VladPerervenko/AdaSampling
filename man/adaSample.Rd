% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/adaSample.R
\name{adaSample}
\alias{adaSample}
\title{Implementation of AdaSampling for positive unlabelled and label noise
learning.}
\usage{
adaSample(Ps, Ns, train.mat, test.mat, classifier = "svm", s = 1, C = 1,
  sampleFactor = 1)
}
\arguments{
\item{Ps}{names (name as index) of positive examples}

\item{Ns}{names (name as index) of negative examples}

\item{train.mat}{training data matrix, without class labels.}

\item{test.mat}{test data matrix, without class labels.}

\item{classifier}{classification algorithm to be used for learning. Current options are
support vector machine, \code{"svm"}, k-nearest neighbour, \code{"knn"}, logistic regression \code{"logit"}, or
linear discriminant analysis \code{"lda"}.}

\item{s}{sets the seed.}

\item{C}{sets how many times to run the classifier, C>1 induces an ensemble learning model.}

\item{sampleFactor}{provides a control on the sample size for resampling.}
}
\value{
a two column matrix providing classification probabilities of each sample 
with respect to positive and negative classes
}
\description{
\code{adaSample()} applies the AdaSampling procedure to reduce noise
in the training set, and subsequently trains a classifier from
the new training set. For each row (observation) in the test set, it
returns the probabilities of it being a positive ("P) or negative
("N") instance, as a two column data frame.
}
\details{
\code{adaSample()} is an adaptive sampling-based noise reduction method
to deal with noisy class labelled data, which acts as a wrapper for
traditional classifiers, such as support vector machines,
k-nearest neighbours, logistic regression, and linear discriminant
analysis.

This process is used to build up a noise-minimized training set
that is derived by iteratively resampling the training set,
(\code{train}) based on probabilities derived after its classification.

This sampled training set is then used to train a classifier, which
is then executed on the test set. \code{adaSample()} returns a series of
predictions for each row of the test set.

Note that this function does not evaluate the quality of the model
and thus does not compare its output to true values of the test set.
To assess please see \code{adaSvmBenchmark()}.
}
\section{References}{

Yang, P., Liu, W., Yang. J. (2017) Positive unlabeled learning via wrapper-based
adaptive sampling. \emph{International Joint Conferences on Artificial Intelligence (IJCAI)}, 3272-3279

Yang, P., Ormerod, J., Liu, W., Ma, C., Zomaya, A., Yang, J.(2018) 
AdaSampling for positive-unlabeled and label noise learning with bioinformatics applications. 
\emph{IEEE Transactions on Cybernetics}, doi:10.1109/TCYB.2018.2816984
}

\examples{
# Load the example dataset
data(brca)
head(brca)

# First, clean up the dataset to transform into the required format.
brca.mat <- apply(X = brca[,-10], MARGIN = 2, FUN = as.numeric)
brca.cls <- sapply(X = brca$cla, FUN = function(x) {ifelse(x == "malignant", 1, 0)})
rownames(brca.mat) <- paste("p", 1:nrow(brca.mat), sep="_")

# Introduce 40\% noise to positive class and 30\% noise to the negative class
set.seed(1)
pos <- which(brca.cls == 1)
neg <- which(brca.cls == 0)
brca.cls.noisy <- brca.cls
brca.cls.noisy[sample(pos, floor(length(pos) * 0.4))] <- 0
brca.cls.noisy[sample(neg, floor(length(neg) * 0.3))] <- 1

# Identify positive and negative examples from the noisy dataset
Ps <- rownames(brca.mat)[which(brca.cls.noisy == 1)]
Ns <- rownames(brca.mat)[which(brca.cls.noisy == 0)]

# Apply AdaSampling method on the noisy data
brca.preds <- adaSample(Ps, Ns, train.mat=brca.mat, test.mat=brca.mat, classifier = "knn")
head(brca.preds)

# Orignal accuracy from the labels
accuracy <- sum(brca.cls.noisy == brca.cls) / length(brca.cls)
accuracy

# Accuracy after applying AdaSampling method
accuracyWithAdaSample <- sum(ifelse(brca.preds[,"P"] > 0.5, 1, 0) == brca.cls) / length(brca.cls)
accuracyWithAdaSample

}
