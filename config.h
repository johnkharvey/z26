
/* config.h for Z26. Not many choices here yet. */

/* Version number */
#define Z26_VERSION "2.13-pre2"

/* Define WINDOWS on Win32 systems for GUI support.
	Actually, there isn't a GUI yet, this doesn't do much:
	#define WINDOWS 1
*/


/*	Define NEW_KEYBOARD to use the new keysym-based keyboard
	code. Eventually this will be the only keyboard code, but it's
	not finished yet.  The other alternative is to use the original
	scancode-based keyboard decoding, which *ONLY WORKS ON WINDOWS*.

	For now, there may be missing keystrokes with the new code,
	which means some of the controls just won't work (yet).

 */
	#define NEW_KEYBOARD 1

/* DEFAULT_SQ_MAX is the size of the sound buffer. Too small and
	sound will break up; too big and sound will lag behind the
	action. Note that if you use the -s option, you need to multiply
	by 3 (e.g. to get a sound buffer of 1024 bytes, use `-s3072' on
	the Z26 command line, or define DEFAULT_SQ_MAX to 1024).

	The original Windows-only version of the code used 2048 for
	this value, which seems reasonable for Win32, but is too darn
	high for Linux.
*/
#ifdef WINDOWS
#	define DEFAULT_SQ_MAX 2048
#else
#	define DEFAULT_SQ_MAX 128
#endif


