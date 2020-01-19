#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use Data::Dumper;
use Mojo::JSON qw(j);

# Esse programa possui a finalidade de converter arquivos de log no formato `Native` [3] do ModSecurity para o formato em JSON [1].
# Ele possui as seguintes funções:
# - Carrega os arquivos na pasta ../dataset/archive (podem ser vários arquivos)
# - Cria os arquivos ../dataset/badqueries.json e ../dataset/goodqueries.json. Os arquivos são separados em eventos interceptados pelo
#     ModSecurity (badqueries) e outros (goodqueries).
# - Faz a leitura de cada arquivo e escreve os eventos nos arquivos JSON de destino. Cada evento é uma linha no arquivo em JSON.
# - Imprime relatório com o número de eventos processados.

# Referências:
# 1. https://www.cryptobells.com/mod_security-json-audit-logs-revisited/
# 2. https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual-(v2.x)#SecAuditLogFormat
# 3. https://www.feistyduck.com/library/modsecurity-handbook-2ed-free/online/ch04-logging.html


# proccess_file lê um arquivo linha por linha e retorna uma referência para dicionário com a seguinte estrutura:
# {
#     'd680650d' => {
#         'B' => [
#                 'GET /assets/images/ HTTP/1.1',
#                 'Connection: keep-alive',
#                 'User-Agent: Mozilla/5.0 (Linux; Android 8.1.0; Moto G (5S) Plus) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.99 Mobile Safari/537.36',
#                 ''
#                 ],
#         'F' => [
#                 'HTTP/1.1 403 Forbidden',
#                 'Content-Length: 236',
#                 'Content-Type: text/html; charset=iso-8859-1',
#                 'X-Content-Type-Options: nosniff',
#                 'Connection: close',
#                 ''
#                 ],
#         'E' => [
#                 ''
#                 ],
#         'A' => [
#                 '[17/Feb/2020:18:06:03 --0300] XksAO7ZWz6wrRugwB4o8eQAAAI0 131.100.166.207 39662 192.168.163.106 8043'
#                 ],
#         'H' => [
#                 'Message: Access denied with code 403 (phase 2). Pattern match...',
#                 'Action: Intercepted (phase 2)',
#                 'Stopwatch: 1581973782879051 756 (- - -)',
#                 'Stopwatch2: 1581973782879051 756; combined=331, p1=108, p2=217, p3=0, p4=0, p5=5, sr=28, sw=1, l=0, gc=0',
#                 'Producer: ModSecurity/X.X.X (http://www.modsecurity.org/); OWASP_CRS/X.X.X.',
#                 'WebApp-Info: "www.example.com" "-" "-"',
#                 'Engine-Mode: "ENABLED"',
#                 ''
#                 ],
#         'Z' => [
#                 ''
#                 ]
#     },
#     ...
sub proccess_file {
    my $filename = shift;

    # Carrega os arquivos
    open my $fh, '<', $filename;

    my $data = {};
    my $config = {};

    while (my $linha = <$fh>) {
        chomp $linha;

        if ( $linha =~ /--(?<id>\w+)-(?<section>\w)--/smx ) {
            $config->{last_id} = $+{id};
            $config->{last_section} = $+{section};

        } else {
            push @{ $data->{ $config->{last_id} }->{ $config->{last_section} } }, $linha;
        }
    }

    close $fh;
    return $data;
}


# extract_json_from_struct recebe a saída da função proccess_file e transforma em uma estrutura semelhante ao formato
#   JSON do AuditLog do ModSecurity.
sub extract_json_from_struct {
    my $filedata = shift;

    # Cada chave/key é o registro de um evento. Iteramos sob eles para ler todos os eventos.
    foreach my $key (keys %{$filedata}) {
        # A - Transaction
        # [17/Feb/2020:18:09:42 --0300] XksBFrZWz6wrRugwB4pA5AAAAJA 103.108.132.234 50770 192.168.163.106 8000
        if ( $filedata->{$key}->{'A'}->[0] =~
            /\[(?<time>[^\]]+)\]\s+
            (?<transation_id>[^\s]+)\s+
            (?<remote_address>[\w:\.]+)\s+
            (?<remote_port>\d+)\s+
            (?<local_address>[\w:\.]+)\s+
            (?<local_port>\d+)/smx) {
                $filedata->{$key}->{'transaction'} = {
                    'time' => $+{time},
                    'transation_id' => $+{transation_id},
                    'remote_address' => $+{remote_address},
                    'remote_port' => int($+{remote_port}),
                    'local_address' => $+{local_address},
                    'local_port' => int($+{local_port}),
                };
                delete $filedata->{$key}->{'A'};
        } else {
            print "Error: ".$filedata->{$key}->{'A'}->[0] . "\n";
            exit;
        }

        # B - Request headers
        $filedata->{$key}->{'request'}->{'request_line'} = shift @{ $filedata->{$key}->{'B'} };
        foreach my $request_header (@{ $filedata->{$key}->{'B'} }) {
            if ( $request_header eq '' ) {
                next;
            }

            my ($header_name,$header_value) = split /:\s*/, $request_header, 2;
            $filedata->{$key}->{'request'}->{'headers'}->{$header_name} = $header_value;
        }
        delete $filedata->{$key}->{'B'};

        # C - request body
        if ( defined $filedata->{$key}->{'C'} ) {
            $filedata->{$key}->{'request'}->{'body'} = join "\n", @{$filedata->{$key}->{'C'}};
            delete $filedata->{$key}->{'C'};
        }


        # F - Response headers
        my $response_msg; # Não será usada.
        my $response_line = shift @{ $filedata->{$key}->{'F'} };
        ($filedata->{$key}->{'response'}->{'protocol'}, $filedata->{$key}->{'response'}->{'status'}, $response_msg) = split / /, $response_line, 3;
        foreach my $response_header (@{ $filedata->{$key}->{'F'} }) {
            if ( $response_header eq '' ) {
                next;
            }

            my ($header_name,$header_value) = split /:\s*/, $response_header, 2;
            $filedata->{$key}->{'response'}->{'headers'}->{$header_name} = $header_value;
        }
        delete $filedata->{$key}->{'F'};

        # H - Audit data
        foreach my $audit_line (@{ $filedata->{$key}->{'H'} }) {
            if ( $audit_line eq '' ) {
                next;
            }

            my ($header_name,$header_value) = split /:\s*/, $audit_line, 2;
            $filedata->{$key}->{'audit_data'}->{lc $header_name} = $header_value;
        }
        delete $filedata->{$key}->{'H'};

        # E & Z
        delete $filedata->{$key}->{'E'};
        delete $filedata->{$key}->{'Z'};
    }
    return $filedata;
}

# Realiza a leitura do nome dos arquivos no diretório.
my $directory = '../dataset/archive/';
opendir my $fd, $directory;
my @file_list = readdir($fd);
closedir($fd);

# Cria os arquivos de destino.
my $events_true = 0;
my $events_false = 0;
open my $true, '>', '../dataset/badqueries.json';
open my $false, '>', '../dataset/goodqueries.json';

# Processa cada um dos arquivos.
my $total_events = 0;
foreach my $file_name (@file_list) {
    my $filedata = proccess_file($directory.$file_name);
    my $json = extract_json_from_struct($filedata);

    foreach my $key (keys %{$json}) {
        my ($method, $uri, $protocol) = split /\s/, $json->{$key}->{'request'}->{'request_line'}, 3;
        if ( defined $json->{$key}->{'audit_data'}->{'action'} ) {
            # print $true j($json->{$key}) . "\n";
            print $true $uri . "\n";
            $events_true++;
        } else {
            # print $false j($json->{$key}) . "\n";
            print $false $uri . "\n";
            $events_false++;
        }
    }

    my @keys = keys %{$json};
    # print "$file_name: $#keys\n";
    $total_events = $total_events + $#keys;
}

# Fecha os arquivos.
close $true;
close $false;

# Imprime relatório de processamento.
print "Foram processados $total_events eventos.\nTrue: $events_true\nFalse: $events_false\n";