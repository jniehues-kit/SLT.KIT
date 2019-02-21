
#ifndef UTIL_H_
#define UTIL_H_

using namespace std;

#define SPACES " \t\r\n"
#define WSPACES L" \t\r\n"

inline string trim_right (const string & s, const string & t = SPACES)
{
    string d (s);
    string::size_type i (d.find_last_not_of (t));
    if (i == string::npos)
        return "";
    else
        return d.erase (d.find_last_not_of (t) + 1) ;
}

inline string trim_left (const string & s, const string & t = SPACES)
{
    string d (s);
    return d.erase (0, s.find_first_not_of (t)) ;
}

inline string trim (const string & s, const string & t = SPACES)
{
    string d (s);
    return trim_left (trim_right (d, t), t) ;
}

inline wstring trim_right (const wstring & s, const wstring & t = WSPACES)
{
    wstring d (s);
    wstring::size_type i (d.find_last_not_of (t));
    if (i == wstring::npos)
        return L"";
    else
        return d.erase (d.find_last_not_of (t) + 1) ;
}

inline wstring trim_left (const wstring & s, const wstring & t = WSPACES)
{
    wstring d (s);
    return d.erase (0, s.find_first_not_of (t)) ;
}

inline wstring trim (const wstring & s, const wstring & t = WSPACES)
{
    wstring d (s);
    return trim_left (trim_right (d, t), t) ;
}

#endif
