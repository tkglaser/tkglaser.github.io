This is an example of using one of the .NET hashing algorithms to hash 
a password into a fixed length string which can then be stored in a fixed 
length database column. I've started from 
this [example implementation](http://www.obviex.com/samples/hash.aspx).

### Password hashing basics
Generally speaking, a hash function always creates the same output for the same input. However, the output does not have to be unique. For example, "mod 5" can be used as a hash function h() for integers:

```
h(3) => 3
h(6) => 1
```
but also 
```
h(8) => 3
```

More advanced hash algorithms are MD5 or SHA which convert an input 
string (like your password) into an output string that looks like random data, 
commonly referred to as the Hash.
```
h("MyPass") => "MyHash"
```
The same input string will always create the same output. Using one of the 
advanced algorithms, it is impossible to "decrypt" the Hash into the original password.

What is possible for an attacker is trying to guess the password based on dictionaries of common words or phrases.

To avoid these dictionary attacks, passwords can be salted.

A **Salt** is a randomly generated string which is added to the password:
```
h("TheSalt" + "MyPass") => "MySaltedHash"
```
In order to verify a password, the Salt needs to be stored as well, for example next to your hash, so your password column in the database would contain:
```
"TheSalt" + "MySaltedHash"
```

### Problems with the reference implementation
Depending on the algorithm and the BASE64 encoding, the string length is not guaranteed. Therefore, the resulting hash must be concatenated to guarantee a certain string length. Since the salt is at the end of the hash, the concatenation will cut off the salt, which makes the verification of the hashed password impossible. In order to solve this, the salt has been fixed to a specific length and stored at the beginning of the hashed string.

### The Implementation
Let's look at the implementation. This should be the minimum namespace references required:
```csharp
using System;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Security.Cryptography;
```
Some constants:
```csharp
// maxHashSize needs to be a multiple of 4 for the Base64 Encoding
protected static readonly int maxHashSize = 48;

// Length of the random salt. Can be any length.
protected static readonly int saltSize = 5;
```

*maxHashSize* is the maximum string length of the generated Hash 
(including the Salt). Note, that this length must be a multiple of 4 
because of the BASE64 encoding. If, for instance, your password column in the 
database is 50 characters wide, a maxHashSize of 48 is a reasonable choice.

*saltSize* is the number of bytes to use for the Salt.

```csharp
public static string ComputeHash(
  string myPassword,
  byte[] saltBytes = null)
{
  // randomly create the Salt
  // unless it has been passed in
  if (saltBytes == null)
  {
    saltBytes = new byte[saltSize];
    RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
    rng.GetNonZeroBytes(saltBytes);
  }

  // Concat the Salt and Password
  byte[] myPasswordBytes = Encoding.UTF8.GetBytes(myPassword);
  byte[] myPasswordWithSaltBytes = 
    saltBytes.Concat(myPasswordBytes).ToArray();

  // Hash the Salt + Password
  HashAlgorithm hash = new SHA512Managed();
  byte[] hashBytes = hash.ComputeHash(myPasswordWithSaltBytes);
  byte[] hashWithSaltBytes = saltBytes.Concat(hashBytes).ToArray();

  // Convert to BASE64 and cut off after the maximum size
  string hashValue = Convert.ToBase64String(hashWithSaltBytes);
  return hashValue.Substring(0, maxHashSize);
}
```
This method creates a random Salt unless a Salt was passed in. 
Then, the Salt is concatenated with the password and hashed. 
For the hashing function, any class that implements HashAlgorithm 
can be used, [see here](http://msdn.microsoft.com/en-us/library/system.security.cryptography.hashalgorithm.aspx) 
for a list. In general, the *Managed classes 
can be used in most cases. If you have special government certification 
requirements, [there are *CNG classes which are FIPS certified](http://stackoverflow.com/questions/211169/cng-cryptoserviceprovider-and-managed-implementations-of-hashalgorithm).
```csharp
public static bool VerifyHash(
  string myPassword,
  string hashValue)
{
  // Convert base64-encoded hash value into a byte array.
  byte[] hashWithSaltBytes = Convert.FromBase64String(hashValue);

  // Copy salt from the beginning of the hash to the new array.
  byte[] saltBytes = hashWithSaltBytes.Take(saltSize).ToArray();

  // Compute a new hash string.
  string expectedHashString = 
    ComputeHash(myPassword, saltBytes);

  // If the computed hash matches the specified hash,
  // the myPassword value must be correct.
  return (hashValue == expectedHashString);
}
```
Let's see it in action:
```csharp
public static void Main (string[] args)
{
  string myPass = "MySecretPassword";
  string myHash = ComputeHash(myPass);

  if (VerifyHash(myPass, myHash))
  {
    Console.WriteLine("The password was correct!");
  }
}
```
All that is left to do is saving myHash to the database to recall it when needed 
to verify a password.

That's it!

Please leave a comment if you find a mistake or have a suggestion. Thanks again 
to the reference implementation, I used as a starting point.