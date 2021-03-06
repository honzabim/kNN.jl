"""

    Implements all three variants of the anomaly detectors based on k-nearest neighbors from
    From outliers to prototypes: Ordering data,
    Stefan Harmelinga and Guido Dornhegea and David Tax and Frank Meinecke and Klaus-Robert Muller, 2005

"""
struct KNNAnomaly{V<:Val}
    t::BruteTree
    X::Matrix
    v::V
end

"""
    function KNNAnomaly(X::Matrix, v::Symbol)

    create the k-nn anomaly detector with variant v::Symbol

"""
KNNAnomaly(X::Matrix, v::Symbol) = KNNAnomaly(BruteTree(X), X, Val(v))

"""
    kappa is the radius of a ball containing all points

"""
function StatsBase.predict(model::KNNAnomaly, x, k, v::V) where {V<:Val{:kappa}}
    inds, dists = NearestNeighbors.knn(model.t, x, k,true)
    map(d -> d[end],dists)
end

"""
    gamma is the average distance to all k-nearest neighbors

"""
function StatsBase.predict(model::KNNAnomaly, x, k, v::V) where {V<:Val{:gamma}}
    inds, dists = NearestNeighbors.knn(model.t, x, k)
    map(d -> mean(d),dists)
end

"""
    delta is the average distance to all k-nearest neighbors

"""
function StatsBase.predict(model::KNNAnomaly, x, k, v::V) where {V<:Val{:delta}}
    inds, dists = NearestNeighbors.knn(model.t, x, k)
    map(i -> vecnorm(x[:,i[1]] - mean(model.X[:,i[2]],2).^2) ,enumerate(inds))
end

StatsBase.predict(model::KNNAnomaly, x, k, v::Symbol) = StatsBase.predict(model, x, k, Val(v))
StatsBase.predict(model::KNNAnomaly, x, k) = StatsBase.predict(model, x, k, model.v)
