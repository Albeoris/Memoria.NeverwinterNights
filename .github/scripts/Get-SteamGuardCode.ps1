[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SharedSecret
)

$secretBytes = [Convert]::FromBase64String($SharedSecret)
$timeSlice = [Math]::Floor([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() / 30)
$timeBytes = [BitConverter]::GetBytes([Int64]$timeSlice)
if ([BitConverter]::IsLittleEndian) { [Array]::Reverse($timeBytes) }

$hmac = [Security.Cryptography.HMACSHA1]::new($secretBytes)
try {
    $hash = $hmac.ComputeHash($timeBytes)
}
finally {
    $hmac.Dispose()
}

$offset = $hash[$hash.Length - 1] -band 0x0f
$codePoint = (($hash[$offset] -band 0x7f) -shl 24) -bor (($hash[$offset + 1] -band 0xff) -shl 16) -bor (($hash[$offset + 2] -band 0xff) -shl 8) -bor ($hash[$offset + 3] -band 0xff)
$alphabet = '23456789BCDFGHJKMNPQRTVWXY'
$code = [Text.StringBuilder]::new(5)
for ($index = 0; $index -lt 5; $index++) {
    [void]$code.Append($alphabet[$codePoint % $alphabet.Length])
    $codePoint = [Math]::Floor($codePoint / $alphabet.Length)
}

$code.ToString()
