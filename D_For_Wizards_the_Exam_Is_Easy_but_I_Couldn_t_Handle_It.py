def count_inversions(arr):
    inv_count = 0
    n = len(arr)
    for i in range(n):
        for j in range(i + 1, n):
            if arr[i] > arr[j]:
                inv_count += 1
    return inv_count

def cyclic_shift(arr, l, r):
    if l == r:
        return arr.copy()
    shifted = arr.copy()
    temp = shifted[l]
    for i in range(l, r):
        if i == r - 1:
            shifted[i] = temp
        else:
            shifted[i] = shifted[i + 1]
        shifted[i] = shifted[i + 1]
    shifted[r] = temp
    return shifted

def find_optimal_shift(n, a):
    initial_inversions = count_inversions(a)
    min_inversions = initial_inversions
    best_l, best_r = 1, 1
    
    for l in range(n):
        for r in range(l, n):
            shifted = cyclic_shift(a, l, r)
            current_inversions = count_inversions(shifted)
            if current_inversions < min_inversions:
                min_inversions = current_inversions
                best_l, best_r = l + 1, r + 1  # Convert to 1-based indexing
    
    return best_l, best_r

def main():
    import sys
    input = sys.stdin.read
    data = input().split()
    
    t = int(data[0])
    index = 1
    results = []
    
    for _ in range(t):
        n = int(data[index])
        index += 1
        a = list(map(int, data[index:index + n]))
        index += n
        
        l, r = find_optimal_shift(n, a)
        results.append(f"{l} {r}")
    
    print('\n'.join(results))

if __name__ == "__main__":
    main()