import sys

def max_subsequences(n, s):
    count_dash = s.count('-')
    count_underscore = n - count_dash  # Since the string contains only '-' and '_'
    
    return (count_dash * (count_dash - 1) // 2) * count_underscore

def main():
    input = sys.stdin.read
    data = input().split()
    
    t = int(data[0])
    index = 1
    results = []
    
    for _ in range(t):
        n = int(data[index])
        s = data[index + 1]
        index += 2
        results.append(str(max_subsequences(n, s)))
    
    sys.stdout.write("\n".join(results) + "\n")

if __name__ == "__main__":
    main()
