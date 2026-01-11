{
  writers,
}:
writers.writePython3 "klvpn_cert_chooser" { } ''
  import fileinput
  import re
  import datetime


  class cert:
      certs = []

      def __init__(self, n):
          self.n = n
          self.fields = {}

      def new_line(self, line):
          m = re.match(r"^\s*(\w+):\s*(.*)$", line)
          if m:
              self.fields[m[1]] = m[2]

      def parse_line(line):
          m = re.match(r"^Object\s+(\d+):", line)
          if m:
              cert.certs.append(cert(m[1]))
          else:
              cert.certs[len(cert.certs) - 1].new_line(line)

      def is_valid(self):
          # The p11tool returns date without preceding 0 in numbers
          exp = self.fields["Expires"].replace("  ", " 0")
          # Thu Nov  4 16:36:16 2021
          try:
              d = datetime.datetime.strptime(exp, "%a %b %d %X %Y")
              return d > datetime.datetime.now()
          except ValueError:
              return False

      def url(self):
          return self.fields["URL"]

      def choose_active():
          for c in cert.certs:
              if c.is_valid():
                  return c


  for line in fileinput.input():
      cert.parse_line(line)

  c = cert.choose_active()

  if c is not None:
      print(c.url())
''
