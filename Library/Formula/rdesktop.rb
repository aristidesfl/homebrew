require 'formula'

class Rdesktop < Formula
  homepage 'http://www.rdesktop.org/'
  url 'https://downloads.sourceforge.net/project/rdesktop/rdesktop/1.8.1/rdesktop-1.8.1.tar.gz'
  sha1 '57bb41f98ddf9eeef875c613d790fee37971d0f8'

  depends_on :x11

  patch :DATA

  def install
    args = ["--prefix=#{prefix}",
            "--disable-credssp",
            "--disable-smartcard", # disable temporally before upstream fix
            "--with-openssl=#{MacOS.sdk_path}/usr",
            "--x-includes=#{MacOS::X11.include}",
            "--x-libraries=#{MacOS::X11.lib}"]
    system "./configure", *args
    system "make install"
  end
end

# Note: The patch below is meant to remove the reference to the undefined symbol
# SCARD_CTL_CODE. Since we are compiling with --disable-smartcard, we don't need
# it anyway (and it should probably have been #ifdefed in the original code).

__END__
diff --git a/scard.c b/scard.c
index caa0745..5521ee9 100644
--- a/scard.c
+++ b/scard.c
@@ -2152,7 +2152,6 @@ TS_SCardControl(STREAM in, STREAM out)
	{
		/* Translate to local encoding */
		dwControlCode = (dwControlCode & 0x3ffc) >> 2;
-		dwControlCode = SCARD_CTL_CODE(dwControlCode);
	}
	else
	{
@@ -2198,7 +2197,7 @@ TS_SCardControl(STREAM in, STREAM out)
	}

 #ifdef PCSCLITE_VERSION_NUMBER
-	if (dwControlCode == SCARD_CTL_CODE(3400))
+	if (0)
	{
		int i;
		SERVER_DWORD cc;
