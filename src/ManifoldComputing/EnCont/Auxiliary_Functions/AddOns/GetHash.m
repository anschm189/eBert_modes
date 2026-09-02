function hash = GetHash(filename)
persistent md
if isempty(md)
    md = java.security.MessageDigest.getInstance('SHA-256');
end
text = fileread(filename);
hash = sprintf('%2.2x', typecast(md.digest(uint8(text)), 'uint8')');
end