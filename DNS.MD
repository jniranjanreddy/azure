# DNS Record Types (Cloudflare / GoDaddy)

Reference for the record types shown in the DNS "Add record" dropdown, with 3 examples each.

---

## A
Maps a hostname to an **IPv4 address**. The most common record type.

1. `example.com → 192.0.2.10`
2. `www.example.com → 192.0.2.10`
3. `app.example.com → 203.0.113.55`

---

## AAAA
Maps a hostname to an **IPv6 address**. Same purpose as A, for IPv6.

1. `example.com → 2606:4700:4700::1111`
2. `www.example.com → 2001:db8::1`
3. `mail.example.com → 2606:4700:4700::1001`

---

## CAA
**Certificate Authority Authorization** — restricts which CAs are allowed to issue SSL/TLS certificates for the domain.

1. `example.com CAA 0 issue "letsencrypt.org"`
2. `example.com CAA 0 issue "digicert.com"`
3. `example.com CAA 0 iodef "mailto:security@example.com"` (report violations)

---

## CERT
Stores a **public key certificate** (PGP, X.509, etc.) in DNS. Rarely used directly by end users.

1. `example.com CERT PGP <base64-cert-data>`
2. `user@example.com CERT PKIX <base64-cert-data>`
3. `host.example.com CERT IPKIX <base64-cert-data>`

---

## CNAME
**Canonical Name** — aliases one hostname to another hostname (not an IP). Cannot coexist with other records on the same name.

1. `www.example.com → example.com`
2. `blog.example.com → ghs.googlehosted.com`
3. `shop.example.com → shops.myshopify.com`

---

## DNSKEY
Holds the **public key** used in DNSSEC to validate signed DNS responses.

1. `example.com DNSKEY 256 3 8 <public-key-data>` (Zone Signing Key)
2. `example.com DNSKEY 257 3 8 <public-key-data>` (Key Signing Key)
3. `sub.example.com DNSKEY 256 3 13 <public-key-data>` (ECDSA algorithm)

---

## DS
**Delegation Signer** — placed at the parent zone/registrar to link to a child zone's DNSKEY, forming the DNSSEC chain of trust.

1. `example.com DS 2371 13 2 <digest>`
2. `sub.example.com DS 5502 8 2 <digest>`
3. `example.com DS 12345 13 1 <digest>` (SHA-1 digest type)

---

## HTTPS
Modern record (RFC 9460) that advertises **HTTP/HTTPS connection parameters** (e.g., HTTP/2/3 support, ALPN) directly in DNS, enabling faster/secure connections without an extra redirect.

1. `example.com HTTPS 1 . alpn="h2,h3"`
2. `www.example.com HTTPS 1 . alpn="h3" port="443"`
3. `example.com HTTPS 1 pool.example.net alpn="h2"` (points to a target name)

---

## LOC
Stores **geographic location** (latitude, longitude, altitude) of a host. Largely legacy/novelty use today.

1. `example.com LOC 37 46 30.000 N 122 25 10.000 W 10m`
2. `office.example.com LOC 40 44 55.000 N 73 59 11.000 W 15m`
3. `dc1.example.com LOC 51 30 26.000 N 0 7 39.000 W 5m`

---

## MX
**Mail Exchange** — specifies the mail server(s) responsible for receiving email for the domain, with a priority value (lower = higher priority).

1. `example.com MX 10 mail.example.com`
2. `example.com MX 1 aspmx.l.google.com` (Google Workspace)
3. `example.com MX 0 example-com.mail.protection.outlook.com` (Microsoft 365)

---

## NAPTR
**Naming Authority Pointer** — used for rewriting/mapping URIs, commonly in VoIP/SIP (ENUM) telephony systems.

1. `example.com NAPTR 100 10 "U" "E2U+sip" "!^.*$!sip:info@example.com!" .`
2. `example.com NAPTR 90 10 "S" "SIP+D2U" "" _sip._udp.example.com`
3. `4.3.2.1.e164.arpa NAPTR 10 100 "u" "E2U+sip" "!^.*$!sip:+1234@example.com!" .`

---

## NS
**Nameserver** — delegates a domain or subdomain to specific authoritative nameservers.

1. `example.com NS ns1.cloudflare.com`
2. `example.com NS ns2.cloudflare.com`
3. `sub.example.com NS ns1.dnsprovider.net` (delegating a subdomain elsewhere)

---

## PTR
**Pointer** — reverse DNS, maps an IP address back to a hostname. Set on the IP's reverse zone (often by the hosting/IP provider, not the domain registrar).

1. `10.113.0.203.in-addr.arpa PTR mail.example.com` (IPv4 reverse for 203.0.113.10)
2. `1.1.1.1.in-addr.arpa PTR one.one.one.one`
3. `1.1.1.0.0.0.0...ip6.arpa PTR host.example.com` (IPv6 reverse)

---

## SOA
**Start of Authority** — required record at the zone apex holding master zone metadata (primary nameserver, admin contact, serial number, refresh/retry/expire/TTL timers). Usually one per zone, auto-managed.

1. `example.com SOA ns1.example.com. admin.example.com. 2026091201 10000 2400 604800 3600`
2. `example.com SOA ns.cloudflare.com. dns.cloudflare.com. 2347562891 10000 2400 604800 3600`
3. `sub.example.com SOA ns1.sub.example.com. hostmaster.sub.example.com. 2026090100 3600 900 1209600 300`

---

## SRV
**Service** — locates a server for a specific service/protocol, including port and priority/weight. Common for SIP, XMPP, Minecraft servers, etc.

1. `_sip._tcp.example.com SRV 10 60 5060 sipserver.example.com`
2. `_xmpp-server._tcp.example.com SRV 5 0 5269 xmpp.example.com`
3. `_minecraft._tcp.example.com SRV 0 5 25565 mc.example.com`

---

## SSHFP
**SSH Fingerprint** — publishes a server's SSH host key fingerprint in DNS so clients can verify it (used with DNSSEC for `VerifyHostKeyDNS`).

1. `host.example.com SSHFP 1 1 <SHA1-fingerprint>` (RSA key)
2. `host.example.com SSHFP 4 2 <SHA256-fingerprint>` (Ed25519 key)
3. `bastion.example.com SSHFP 3 2 <SHA256-fingerprint>` (ECDSA key)

---

## TLSA
**TLS Association** (DANE) — binds a TLS certificate to a hostname/port in DNS, letting clients validate certs without relying solely on CAs.

1. `_443._tcp.example.com TLSA 3 1 1 <cert-hash>`
2. `_25._tcp.mail.example.com TLSA 2 1 1 <ca-hash>` (SMTP over DANE)
3. `_443._tcp.www.example.com TLSA 1 0 2 <public-key-hash>`

---

## TXT
**Text** — arbitrary string data, widely used for domain verification and email authentication.

1. `example.com TXT "v=spf1 include:_spf.google.com ~all"` (SPF)
2. `default._domainkey.example.com TXT "v=DKIM1; k=rsa; p=<public-key>"` (DKIM)
3. `_dmarc.example.com TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com"` (DMARC)

---

## URI
Maps a name to a **URI** with priority and weight, similar in spirit to SRV but for direct URLs.

1. `example.com URI 10 1 "https://example.com/"`
2. `_ftp.example.com URI 10 5 "ftp://ftp.example.com/"`
3. `_acme-challenge.example.com URI 0 0 "https://ca.example.com/verify"`

---

### Quick-reference summary

| Type | Purpose |
|------|---------|
| A | Hostname → IPv4 |
| AAAA | Hostname → IPv6 |
| CAA | Restrict cert issuers |
| CERT | Store public key certificates |
| CNAME | Hostname → hostname (alias) |
| DNSKEY | DNSSEC public key |
| DS | DNSSEC parent-child trust link |
| HTTPS | Advertise HTTP(S) connection params |
| LOC | Geographic location |
| MX | Mail server routing |
| NAPTR | URI rewriting (VoIP/SIP) |
| NS | Nameserver delegation |
| PTR | Reverse DNS (IP → hostname) |
| SOA | Zone authority metadata |
| SRV | Service host/port location |
| SSHFP | SSH key fingerprint |
| TLSA | TLS cert association (DANE) |
| TXT | Arbitrary text (SPF/DKIM/DMARC/verification) |
| URI | Name → URI mapping |
