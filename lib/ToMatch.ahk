 /*
    Function: ToMatch
        转换字符串为可用于RegExMatch的字符串
    
    Parameters:
        aStr - 字符串
    
    Return:
        返回字符串
*/
    
ToMatch(str)
{
    str := RegExReplace(str,"\+|\?|\.|\-|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
    Return RegExReplace(str,"\s","\s")
}
