def generate_sample_list(user_limit):
    user_limit = user_limit
    sample_list = []
    for i in range(1, user_limit):
        if i * (i - 2) % 3 == 0:
            sample_list.append(i**2)
    return sample_list

def list_comprehension(limit):
    new_list = [i ** 2 for i in range(1, limit) if i * (i - 2) % 3 == 0]
    return new_list

def list_reverse(input_list):
    input_list = list(input_list)
    input_list = input_list[::-1]
   # loop_len = int(len(input_list)/2)
   # list_len = len(input_list) -1
   # for i in range(loop_len):
   #     input_list[i],input_list[list_len] = input_list[list_len],input_list[i]
   #     list_len = list_len -1
   # input_list= "".join(input_list)
    return input_list


def fib(n):
    if n <= 1:
        return 1
    a, b = 1, 1

    for i in range(2, n + 1):
        a, b = b, a + b

    return b

def fib1(n):
    if n == 0 or n == 1:
        return 1
    else:
        return fib1(n-1) + fib1(n-2)


def build_in_sort(input_list):
    print(input_list)
    input_list = sorted(input_list)
    return input_list

def bubble_sort(input_list):
    loop_len = len(input_list)
    for i in range(loop_len):
        for j in range(0, loop_len-i-1):
            if input_list[j] > input_list[j+1]:
                input_list[j], input_list[j+1] = input_list[j+1], input_list[j]
    return input_list


def quick_sort(input_list):
    if len(input_list) <= 1:
        return input_list
    pivot = input_list[int(len(input_list)/2)]
    left = [x for x in input_list if x < pivot]
    print("left",pivot, left)
    middle = [x for x in input_list if x == pivot]
    print("middle", pivot)
    right = [x for x in input_list if x > pivot]
    print("right", pivot, right)
    return quick_sort(left) + middle + quick_sort(right)


def lyric_counter():
    try:
        local_file = open('lyric', 'r')
    except IOError:
        print
        "no file found"
    else:
        lyric_content = local_file.read()
        words = re.findall(r'\w+', lyric_content)
        word_list = []
        for i in words:
            word_list.append(i)

    word_set = list(set(word_list))

    word_freq = []
    for w in word_set:
        word_freq.append("0")

    for y in word_list:

        for x in range(int(len(word_set))):
            if y == word_set[x]:
                word_freq[x] = int(word_freq[x]) + 1
    # print word_freq
    # print word_set
    new_l = zip(word_freq, word_set)
    new_l.sort(reverse=True)
    for ii in range(10):
        print
        new_l[ii]


if __name__ == '__main__':
    input_list = [1,3,5,9,8,7,6,5]
    a = generate_sample_list(10)
    print(a)