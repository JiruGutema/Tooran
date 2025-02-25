def min_operations_to_sum(n, k, p):
    min_possible_sum = -n * p
    max_possible_sum = n * p
    
    if k < min_possible_sum or k > max_possible_sum:
        return -1
    
    remainder = abs(k)
    
    return (remainder + p - 1) // p


def solve():
    t = int(input())
    results = []
    for _ in range(t):
        n, k, p = map(int, input().split())
        results.append(str(min_operations_to_sum(n, k, p)))
    
    print("\n".join(results))


if __name__ == "__main__":
    solve()
