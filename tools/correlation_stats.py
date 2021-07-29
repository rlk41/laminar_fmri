import numpy as np
from scipy.stats import pearsonr
from scipy.special import betainc
from numba import jit
'''
https://stackoverflow.com/questions/24432101/correlation-coefficients-and-p-values-for-all-pairs-of-rows-of-a-matrix
'''

def corrcoef(matrix):
    r = np.corrcoef(matrix)
    rf = r[np.triu_indices(r.shape[0], 1)]
    df = matrix.shape[1] - 2 # n-2 = df
    ts = rf * rf * (df / (1 - rf * rf)) # r^2 * df/(1 - r^2)
    pf = betainc(0.5 * df, 0.5, df / (df + ts))
    p = np.zeros(shape=r.shape)
    p[np.triu_indices(p.shape[0], 1)] = pf
    p[np.tril_indices(p.shape[0], -1)] = p.T[np.tril_indices(p.shape[0], -1)]
    p[np.diag_indices(p.shape[0])] = np.ones(p.shape[0])
    return r, p

#@jit(nopython=True)
def corrcoef_loop(matrix):
    rows, cols = matrix.shape[0], matrix.shape[1]
    r = np.ones(shape=(rows, rows))
    p = np.ones(shape=(rows, rows))
    for i in range(rows):
        for j in range(i+1, rows):
            r_, p_ = pearsonr(matrix[i], matrix[j])
            r[i, j] = r[j, i] = r_
            p[i, j] = p[j, i] = p_
    return r, p

def test_corrcoef():
    a = np.array([
        [1, 2, 3, 4],
        [1, 3, 1, 4],
        [8, 3, 8, 5],
        [2, 3, 2, 1]])

    r1, p1 = corrcoef(a)
    r2, p2 = corrcoef_loop(a)

    assert np.allclose(r1, r2)
    assert np.allclose(p1, p2)

def test_timing():
    import time
    a = np.random.randn(100, 2500)

    def timing(func, *args, **kwargs):
        t0 = time.time()
        loops = 10
        for _ in range(loops):
            func(*args, **kwargs)
        print('{} takes {} seconds loops={}'.format(
            func.__name__, time.time() - t0, loops))

    timing(corrcoef, a)
    timing(corrcoef_loop, a)


if __name__ == '__main__':
    test_corrcoef()
    test_timing()