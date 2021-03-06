/*               -*- mode: c++ -*-

   DO NOT EDIT THIS FILE -- CHANGES WILL BE LOST!

   [Wed Dec 12 09:09:16 BRST 2012] This file was automatically generated by
   applying the script "./devscripts/extract_templates.tcl" to the template
   declarations in source file "src/TestSuite/TestSuite.H" for types [byte,
   float]
*/
#ifndef INST_CLASS
#  define INST_CLASS
#endif
#ifdef INST_NAMESPACE
namespace INST_NAMESPACE {
#endif
template /** Return the truth value of the comparison. */ bool INST_CLASS requireEq(const Image<byte>& expr, const Image<byte>& expected, const char* srcfile, int line, const char* expr_str);
template /** Return the truth value of the comparison. */ bool INST_CLASS requireEq(const Image< PixRGB<byte> >& expr, const Image< PixRGB<byte> >& expected, const char* srcfile, int line, const char* expr_str);
template /** Return the truth value of the comparison. */ bool INST_CLASS requireEq(const Image<float>& expr, const Image<float>& expected, const char* srcfile, int line, const char* expr_str);
template /** Return the truth value of the comparison. */ bool INST_CLASS requireEq(const Image< PixRGB<float> >& expr, const Image< PixRGB<float> >& expected, const char* srcfile, int line, const char* expr_str);
#ifdef INST_NAMESPACE
}
#endif
