def create_key(n, x):
    if n == 1:
        return [x]
    
    k = 0
    while (1 << k) - 1 < x:
        k += 1
    
    if k > n:
        k = n
    
    a = list(range(k))
    a.extend([x] * (n - k))
    
    return a

def main():
    import sys
    input = sys.stdin.read
    data = input().split()
    
    t = int(data[0])
    index = 1
    results = []
    
    for _ in range(t):
        n = int(data[index])
        x = int(data[index + 1])
        index += 2
        
        key = create_key(n, x)
        results.append(' '.join(map(str, key)))
    
    print('\n'.join(results))

if __name__ == "__main__":
    main()