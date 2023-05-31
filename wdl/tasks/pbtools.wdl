version 1.0

task pbSkera {
    meta {
        description: "Given hifi reads, spilts MAS 8x or 16x array structure using provided adapters"
    }
# ------------------------------------------------
#Inputs required
    input {
        # Required:
        File hifi_bam
        File mas_adapters_fasta
        Int num_threads
        String gcs_output_dir
        # Optional:
        Int? mem_gb
        Int? preemptible_attempts
        Int? disk_space_gb
        Int? cpu
        Int? boot_disk_size_gb
    }
    # Computing required disk size
    Float input_files_size_gb = 2.5*(size(hifi_bam, "GiB"))
    Int default_ram_mb = 4096
    Int default_disk_space_gb = ceil((input_files_size_gb * 2) + 1024)
    Int default_boot_disk_size_gb = 15

    # Mem is in units of GB but our command and memory runtime values are in MB
    Int machine_mem = if defined(mem_gb) then mem_gb * 1024 else default_ram_mb

    command <<<
        sampleid=`echo $test | awk -F '/' '{print $NF}' | awk -F '.hifi_reads.bam' '{print $1}'`
        out_skera=~{gcs_output_dir}${sampleid}.skera.bam
        skera split –j ~{num_threads} ~{hifi_bam} ${out_skera}
    >>>
    # ------------------------------------------------
    # Outputs:
    output {
        # Default output file name:
        File skera_out         = "${out_skera}"
    }

# ------------------------------------------------
# Runtime settings:
    runtime {
    docker: "us-east4-docker.pkg.dev/methods-dev-lab/masseq-dataproc/masseq_prod:tag1"
    memory: machine_mem + " MB"
    disks: "local-disk " + select_first([disk_space_gb, default_disk_space_gb])
    bootDiskSizeGb: select_first([boot_disk_size_gb, default_boot_disk_size_gb])
    preemptible: select_first([preemptible_attempts, 0])
    cpu: select_first([cpu, 1])
    }

}

