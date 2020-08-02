// OSCE.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
using namespace std;

char * string_decoder(char * str) {
    int len;
    int a = 0; // ecx
    int b = 0; // edx

    len = strlen(str);

    if (len <= 0) {
        str[a] = 0;
        return str;
    }

    while (b < len) {
        str[a] = str[b];
        b = b + 3;
        a = a + 1;
    }

    str[a] = 0;
    return str;

}

char* string_encoder(char* str) {
    int len; int i = 0;
    len = strlen(str);

    if (len <= 0) {
        str[i] = 0;
        return str;
    }

    char* result = (char*)malloc(len * 3 + 1);

    int j = 0;
    char c;
    while (i < len) {
        c = str[i];
        result[j] = c;
        j++;
        if (i == len - 1) {
            break;
        }
        result[j] = c + 5;
        j++;
        result[j] = c + 10;
        j++;
        i++;
    }

    result[j] = 0;
    return result;
}

int main()
{
    std::cout << "Hello" << endl;

    //char str[] = "SX]OTYFKPTY^W\\aAFKRW\\E";
    char str[] = "SOFTWARE";

    std::cout
        << "Str : " << str << endl
        << "Str lenght : " << strlen(str) << endl;

    std::cout << "Result : "
        //<< string_decoder(str)
        << string_encoder(str)
        << endl;

    system("pause");
}


