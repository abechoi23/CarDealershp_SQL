import re

# Your task in this kata is to implement a function that calculates the sum of the integers inside a string. For example, in the string "The30quick20brown10f0x1203jumps914ov3r1349the102l4zy dog", the sum of the integers is 3635.
# Note: only positive integers will be tested.


def sum_of_integers_in_string(string):
    current_number = ""
    total = 0
    for c in string:
        if c.isdigit():
            current_number += c
        else:
            if current_number:
                total += int(current_number)
                current_number = ""
    if current_number:
        total += int(current_number)
    return total

string = "The30quick20brown10f0x1203jumps914ov3r1349the102l4zy dog"
print(sum_of_integers_in_string(string))



def sum_of_integers_in_string(s):
    integers = re.findall(r'\d+', s)
    return sum(map(int, integers))

s = "The30quick20brown10f0x1203jumps914ov3r1349the102l4zy dog"
print(sum_of_integers_in_string(s))