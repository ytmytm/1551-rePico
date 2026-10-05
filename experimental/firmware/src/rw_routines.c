/**********************************
 * read and write image routines
 *
 * Author: F00K42
 * Last change: 2026/06/21
 ***********************************/

#include "rw_routines.h"
#include "menu_image.h"
#include "globals.h"
#include "gcr.h"
#include "gui_constants.h"

int8_t read_disk(FIL* fd, const int image_type, FILINFO fileinfo)
{
    uint8_t buffer[4];
    uint32_t offset = 0;
    int8_t  last_track = -99;
    UINT    bytes_read;
    FRESULT fr;

    id1 = 0xFF;
    id2 = 0xFF;

    switch(image_type)
    {
        ///////////////////////////////////////////////////////////////////////////
        case G64_IMAGE: // G64
        {
            uint8_t* P = d64_sector_puffer; // use this d64_buffer as temporary storage
            fr = f_read(fd, P, sizeof(g64_head), &bytes_read);
            if((FR_OK != fr) || (sizeof(g64_head) != bytes_read))
            {
                last_track = -bytes_read;
                break;
            }

            if (0 != strncmp(g64_head, P, 8)) // we accept "GCR-1541" for the header
            {
                last_track = -2;
                break;
            }

            // read the jumptable for track-offsets and track count
            fr = f_read(fd, g64_jumptable, sizeof(g64_jumptable), &bytes_read);
            if((FR_OK != fr) || (sizeof(g64_jumptable) != bytes_read))
            {
                last_track = -3;
                break;
            }
            // read the speedtable for track-speeds
            fr = f_read(fd, g64_speedtable, sizeof(g64_speedtable), &bytes_read);
            if((FR_OK != fr) || (sizeof(g64_speedtable) != bytes_read))
            {
                last_track = -4;
                break;
            }

            for(uint8_t track_nr=0; track_nr<G64_TRACKCOUNT; track_nr++)
            {
                offset = g64_jumptable[track_nr<<1];
                if (0 == offset)
                {
                    // we clean existing data in case there is no trackdata stored.
                    memset(g64_tracks[track_nr], 0x00, G64_TRACKSIZE);
                    continue;
                }
                // found some track-offset .. now read the track itself
                if (FR_OK != f_lseek(fd, offset))
                {
                    last_track = -5;
                    break;
                }

                // read track length and store it.
                fr = f_read(fd, &g64_tracklen[track_nr], sizeof(g64_tracklen[0]), &bytes_read);
                if ((FR_OK != fr) || (sizeof(g64_tracklen[0]) != bytes_read))
                {
                    last_track = -6;
                    break;
                }

                // read track data itself
                fr = f_read(fd, g64_tracks[track_nr], g64_tracklen[track_nr], &bytes_read);
                if ((FR_OK != fr) || (g64_tracklen[track_nr] != bytes_read))
                {
                    last_track = -7;
                    break;
                }

                // fill up the remaining bytes
                memset(&g64_tracks[track_nr][g64_tracklen[track_nr]], 0x55, G64_TRACKSIZE-g64_tracklen[track_nr]);

                last_track=track_nr;
            }
            if (0<last_track)
            {
                // extract id2+id1 from GCR stream...
                P = g64_tracks[last_track];
                const uint8_t *P_end = &g64_tracks[last_track][g64_tracklen[last_track]];

                // find first track-marker .. FF FF 52 ... FF FF 55
                do
                {
                    while((GCR_SYNCMARK != *P++) && (P<P_end)) { };    // find first FF

                    if (P>=P_end) { id1 = 0x7F; id2 = 0x7F; break; }

                    if (GCR_SYNCMARK == *P++)           // find second FF
                    {
                        while(GCR_SYNCMARK == *P) { ++P; }; // repeat until no more FF are found
                        if (0x52 == *P)                 // check for header-id
                        {
                            break;
                        }
                    }
                } while(1);
                if (0x7F != id1)
                {
                    P += 5; // skip the header

                    // lets extract the given FloppyID for further readback of GCR...
                    ConvertFromGCR(P, d64_sector_puffer);
                    id2 = d64_sector_puffer[0];
                    id1 = d64_sector_puffer[1];
                }
            }
        }
        break;

        case D64_IMAGE: // D64
        {
            // now convert the D64 to GCR raw-data and fill G64 structures

            // extract id-fields from directory track for checksum calculation
            // assumption, disk has a dir in track 18 in DOS-format where ID fiels are populated
            offset = (((uint32_t) d64_track_offset[DIRECTORY_TRACK]) << 8) + DIR_ID_OFFSET;
            if (FR_OK == f_lseek(fd, offset))
            {
                fr = f_read(fd, buffer, 2, &bytes_read);
                if ((FR_OK == fr) && (2 == bytes_read))
                {
                    id1 = buffer[0];
                    id2 = buffer[1];
                }
            }

            memset(g64_jumptable,  0, sizeof(g64_jumptable));
            memset(g64_speedtable, 0, sizeof(g64_speedtable));

            for(uint8_t track_nr=0; track_nr<G64_TRACKCOUNT; ++track_nr)
            {
                offset = ((uint32_t) d64_track_offset[track_nr]) << 8;   // we store only 16bit values;
                uint8_t num_of_sectors = d64_sector_count[d64_track_zone[track_nr]];

                if (FR_OK != f_lseek(fd, offset))
                {
                    break;
                }

                fr = f_read(fd, &d64_sector_puffer[1], num_of_sectors*D64_SECTOR_SIZE, &bytes_read);
                if ((FR_OK != fr) || ((num_of_sectors*D64_SECTOR_SIZE) != bytes_read))
                {
                    break;
                }

                g64_jumptable[track_nr*2]  = (uint32_t) (G64_HEADERSIZE+track_nr*(G64_TRACKSIZE+sizeof(g64_tracklen[0])));
                g64_speedtable[track_nr*2] = (uint32_t) (g64_speedzones[d64_track_zone[track_nr]]);

                convert_d64track2gcr(track_nr, id1, id2);

                last_track = track_nr;
            }
        }
        break;

        case PRG_IMAGE: // PRG Datei
        {
            const uint8_t id_buffer[] = product_disk_id_s;      // disk-id
            id1 = id_buffer[0];
            id2 = id_buffer[1];
            const uint8_t num_max_tracks = MAX_TRACKS;
            generate_empty_image(id1,id2,num_max_tracks);

            // generates a prg_file starting from PRGFILE_TRACK
            size_t buffer_size = fileinfo.fsize;
            size_t buffer_left;
            int8_t file_track = PRGFILE_TRACK, next_file_track = PRGFILE_TRACK;
            uint8_t* file_buffer_pointer = g64_tracks[SCRATCH_TRACK];

            if (FR_OK != f_lseek(fd, 0))
            {
                break;
            }
            fr = f_read(fd, file_buffer_pointer, buffer_size, &bytes_read);
            if ((FR_OK != fr) || (bytes_read!=buffer_size))
            {
                last_track = -bytes_read;
                break;
            }
            uint8_t prev_sector;
            do
            {
                buffer_left = buffer_to_track(file_buffer_pointer, buffer_size, file_track, &prev_sector);
                if (buffer_left>0)
                {
                    next_file_track = file_track-1;
                    file_buffer_pointer += (buffer_size-buffer_left);
                    buffer_size = buffer_left;
                    // last sector ?? -> update last sector-chain-pointer to new "file_track,0"...
                    d64_sector_puffer[1+prev_sector*D64_SECTOR_SIZE]=next_file_track+1;
                    d64_sector_puffer[1+prev_sector*D64_SECTOR_SIZE+1]=0;
                }
                convert_d64track2gcr(file_track, id1, id2);
                file_track = next_file_track;
                /* code */
            } while ((buffer_left>0) && (file_track>=0));


            memset(d64_sector_puffer, 0, sizeof(d64_sector_puffer));
            for(uint8_t track_nr=SCRATCH_TRACK; track_nr<num_max_tracks; ++track_nr)
            {
                convert_d64track2gcr(track_nr, id1, id2);
            }

            generate_bam("PRG-LOADER", id_buffer);
            // create a file-entry in the directory...
            char FILENAME[16]={0xA0};
            size_t namelen = strlen(fileinfo.fname)-4;  //remove the ".prg"
            if (namelen>16) {namelen=16;}
            memcpy(FILENAME,fileinfo.fname,namelen);
            generate_directory_entry(FILENAME, CBMDOS_TYPE_PRG, PRGFILE_TRACK,0,((uint16_t) (fileinfo.fsize/254))+1);
            convert_d64track2gcr(DIRECTORY_TRACK,id1,id2);

            last_track = num_max_tracks-1;
            // done
        }
        break;
        default: break;
    }
    return last_track;
}

int8_t write_disk(FIL* fd, const int image_type, const uint8_t num_tracks)
{
    UINT bytes_write;
    int8_t last_track = -1;
    FRESULT fr;

    block_data_changes = true;  // block changes to gcr-track data while we dump it

    switch(image_type)
    {
        ///////////////////////////////////////////////////////////////////////////
        case G64_IMAGE:	// G64
        {
            // GCR-1541 header
            fr = f_write(fd, g64_head, sizeof(g64_head),&bytes_write);
            if ((FR_OK != fr) || (sizeof(g64_head) != bytes_write))
            {
                last_track = -fr-20;
                break;
            }

            // jumptable
            fr = f_write(fd, g64_jumptable, sizeof(g64_jumptable),&bytes_write);
            if ((FR_OK != fr) || (sizeof(g64_jumptable) != bytes_write))
            {
                last_track = -fr-40;
                break;
            }

            // speedtable
            fr = f_write(fd, g64_speedtable, sizeof(g64_speedtable),&bytes_write);
            if ((FR_OK != fr) || (sizeof(g64_speedtable) != bytes_write))
            {
                last_track = -fr-60;
                break;
            }

            // raw-tracks
            for (int track_nr=0; track_nr<num_tracks; track_nr++)
            {
                fr = f_write(fd, &g64_tracklen[track_nr], sizeof(g64_tracklen[0]),&bytes_write);
                if ((FR_OK != fr) || (sizeof(g64_tracklen[0]) != bytes_write))
                {
                    last_track = -fr-80;
                    break;
                }

                UINT track_write_len = G64_TRACKSIZE;
                if (num_tracks > (track_nr+1))
                {
                    if (0 != g64_jumptable[(track_nr+1)*2])
                    {
                        track_write_len = g64_jumptable[(track_nr+1)*2]-g64_jumptable[track_nr*2]-sizeof(g64_tracklen[track_nr]);
                    }
                }

                fr = f_write(fd, &g64_tracks[track_nr], track_write_len,&bytes_write);
                if ((FR_OK != fr) || (track_write_len != bytes_write))
                {
                    last_track = -fr-80;
                    break;
                }
                last_track = track_nr;
            }
            break;
        }
        case D64_IMAGE:
        {
            uint8_t temp;

            last_track = 0;
            for (int track_nr=0; track_nr<num_tracks; track_nr++)
            {
                uint8_t* P = g64_tracks[track_nr];
                uint8_t sector_nr = d64_sector_count[d64_track_zone[track_nr]];
                uint8_t* P_end = &g64_tracks[track_nr][g64_tracklen[track_nr]];

                int32_t offset_track = ((int32_t) d64_track_offset[track_nr]) << 8;   // we store only 16bit values;

                // find first track-marker .. FF FF 52 ... FF FF 55
                do
                {
                    // tricky thing.. while searching for first track-marker
                    //  copy all "wrapped" bytes of last sector to the end again.
                    while((temp = *P++) != GCR_SYNCMARK) { *P_end++ = temp; };
                    if (*P++ == GCR_SYNCMARK)
                    {
                        while(*P == GCR_SYNCMARK) { ++P; };
                        if (*P == 0x52)
                        {
                            break;
                        }
                    }
                } while(1);
                ConvertFromGCR(P, d64_sector_puffer);
                if ((track_nr+1) != d64_sector_puffer[3])
                {
                    break;
                }
                P += 5; // skip the header
                int32_t offset = offset_track + (d64_sector_puffer[2]*D64_SECTOR_SIZE);
                fr = f_lseek(fd, offset);
                if (FR_OK != fr)
                {
                    last_track = -fr-40;
                    break;
                }

                // lets extract the given FloppyID for further readback of GCR...
                // ConvertFromGCR(P, d64_sector_puffer);
                // id2 = d64_sector_puffer[0];
                // id1 = d64_sector_puffer[1];
                P += 5; // skip the header-gap-bytes
                // find sector-marker
                do
                {
                    while(*P++ != GCR_SYNCMARK) { };
                    if (*P++ == GCR_SYNCMARK)
                    {
                        while(*P == GCR_SYNCMARK) { ++P; };
                        if (*P == 0x55)
                        {
                            break;
                        }
                    }
                } while(1);
                // ----
                uint8_t* Out_P = d64_sector_puffer;
                for(int i=0; i<65; ++i)
                {
                    ConvertFromGCR(P, Out_P);
                    P += 5;
                    Out_P += 4;
                }
                fr = f_write(fd, &d64_sector_puffer[1], D64_SECTOR_SIZE,&bytes_write);
                if ((FR_OK != fr) || (D64_SECTOR_SIZE != bytes_write))
                {
                    last_track = -fr-60;
                    break;
                }

                for(uint8_t num=0; num<(sector_nr-1); ++num)
                {
                    // find track-marker .. FF FF 52 ... FF FF 55
                    do
                    {
                        while(*P++ != GCR_SYNCMARK) { };
                        if (*P++ == GCR_SYNCMARK)
                        {
                            while(*P == GCR_SYNCMARK) { ++P; };
                            if (*P == 0x52)
                            {
                                break;
                            }
                        }
                    } while(1);
                    ConvertFromGCR(P, d64_sector_puffer);
                    if ((track_nr+1) != d64_sector_puffer[3])
                    {
                        break;
                    }
                    P += 4;
                    offset = offset_track + (d64_sector_puffer[2]*D64_SECTOR_SIZE);
                    fr = f_lseek(fd, offset);
                    if (FR_OK != fr)
                    {
                        last_track = -fr-20;
                        break;
                    }

                    // find sector-marker
                    do
                    {
                        while(*P++ != GCR_SYNCMARK) { };
                        if (*P++ == GCR_SYNCMARK)
                        {
                            while(*P == GCR_SYNCMARK) { ++P; };
                            if (*P == 0x55)
                            {
                                break;
                            }
                        }
                    } while(1);
                    // ----
                    Out_P = d64_sector_puffer;
                    for(int i=0; i<65; ++i)
                    {
                        ConvertFromGCR(P, Out_P);
                        P += 5;
                        Out_P += 4;
                    }
                    fr = f_write(fd, &d64_sector_puffer[1], D64_SECTOR_SIZE,&bytes_write);
                    if ((FR_OK != fr) || (D64_SECTOR_SIZE != bytes_write))
                    {
                        last_track = -fr;
                        break;
                    }
                }
                if (0 <= last_track)
                {
                    last_track = track_nr;
                }
            }
            break;
        }
        default: break;
    }
    block_data_changes = false; // accept incomming data again

    return last_track;
}

void convert_d64track2gcr(uint8_t track_nr, uint8_t image_id1, uint8_t image_id2)
{
    uint8_t* P;
    uint8_t buffer[4];
    uint8_t header_bytes[5];
    uint8_t* current_sector;

    const uint8_t num_of_sectors = d64_sector_count[d64_track_zone[track_nr]];
    const uint8_t chksum_trackid = (track_nr+1) ^ image_id2 ^ image_id1;
    const uint8_t gap_size = d64_sector_gap[d64_track_zone[track_nr]];

    buffer[0] = image_id2;
    buffer[1] = image_id1;
    buffer[2] = 0x0F;
    buffer[3] = 0x0F;
    ConvertToGCR(buffer, header_bytes);

    P = g64_tracks[track_nr];

    current_sector = d64_sector_puffer;

    for(uint8_t sector_nr=0; sector_nr < num_of_sectors; ++sector_nr)
    {
        uint8_t old_byte0 = current_sector[0];
        current_sector[0] = 0x07;                   // data-marker for all sectors

        P[0] = GCR_SYNCMARK;								// SYNC
        P[1] = GCR_SYNCMARK;								// SYNC
        P[2] = GCR_SYNCMARK;								// SYNC
        P[3] = GCR_SYNCMARK;								// SYNC
        P[4] = GCR_SYNCMARK;								// SYNC

        buffer[0] = 0x08;							// Header Markierung
        buffer[1] = sector_nr ^ chksum_trackid;     // Checksumme
        buffer[2] = sector_nr;
        buffer[3] = track_nr+1;
        ConvertToGCR(buffer, &P[5]);

        P[10] = header_bytes[0];                     // fill in constant header
        P[11] = header_bytes[1];                     //  bytes containing
        P[12] = header_bytes[2];                     //  disk-id2 & id1
        P[13] = header_bytes[3];
        P[14] = header_bytes[4];
        P += 15;

        // GAP Bytes als Lücke
        for (uint8_t i = HEADER_GAP_BYTES; i>0; --i)
        {
            *P++ = 0x55;
        }

        // SYNC
        *P++ = GCR_SYNCMARK;								// SYNC
        *P++ = GCR_SYNCMARK;								// SYNC
        *P++ = GCR_SYNCMARK;								// SYNC
        *P++ = GCR_SYNCMARK;								// SYNC
        *P++ = GCR_SYNCMARK;								// SYNC

        uint8_t SUM = 0x07;     // checksum is prefilled with data-marker
                        // -> the complete buffer can be processed
        for (int i=0; i<257; ++i)
        {
            SUM ^= current_sector[i];
        }

        for (int i=0; i<256; i+=4)
        {
            ConvertToGCR(&(current_sector[i]), P);
            P += 5;
        }

        buffer[0] = current_sector[256];
        buffer[1] = SUM;   // Checksum
        buffer[2] = 0;
        buffer[3] = 0;
        ConvertToGCR(buffer, P);
        P += 5;

        // GCR Bytes als Lücken auffüllen (sorgt für eine Gleichverteilung)
        memset(P, 0x55, gap_size);
        P += gap_size;
        current_sector[0] = old_byte0;
        current_sector += 256;
    }
    g64_tracklen[track_nr]=(uint16_t) (P - g64_tracks[track_nr]);

    memset(P, 0x55, G64_TRACKSIZE-(P - g64_tracks[track_nr]));
}

void convert_gcr2d64track(uint8_t track_nr)
{
    uint8_t* P = g64_tracks[track_nr];
    uint8_t* P_end = &g64_tracks[track_nr][g64_tracklen[track_nr]];
    uint8_t* Out_P;
    uint8_t sector_nr = d64_sector_count[d64_track_zone[track_nr]];
    int32_t offset = 0;

    uint8_t convert_puffer[5];

    // find first track-marker .. FF FF 52 ... FF FF 55
    do
    {
        // tricky thing.. while searching for first track-marker
        //  copy all "wrapped" bytes of last sector to the end again.
        uint8_t temp;
        while((temp = *P++) != GCR_SYNCMARK) { *P_end++ = temp; };
        if (*P++ == GCR_SYNCMARK)
        {
            while(*P == GCR_SYNCMARK) { ++P; };
            if (*P == 0x52)
            {
                break;
            }
        }
    } while(1);
    ConvertFromGCR(P, convert_puffer);
    if ((track_nr+1) != convert_puffer[3])
    {
        return;
    }
    offset = (int32_t) convert_puffer[2]*D64_SECTOR_SIZE;
    P += 5; // skip the header
    P += 5; // skip the header-gap-bytes

    // find sector-marker
    do
    {
        while(*P++ != GCR_SYNCMARK) { };
        if (*P++ == GCR_SYNCMARK)
        {
            while(*P == GCR_SYNCMARK) { ++P; };
            if (*P == 0x55)
            {
                break;
            }
        }
    } while(1);
    // ----
    convert_puffer[0] = d64_sector_puffer[offset];   // save first byte of the sector
    convert_puffer[1] = d64_sector_puffer[offset+D64_SECTOR_SIZE+1];
    convert_puffer[2] = d64_sector_puffer[offset+D64_SECTOR_SIZE+2];
    convert_puffer[3] = d64_sector_puffer[offset+D64_SECTOR_SIZE+3];
    Out_P = &d64_sector_puffer[offset];
    for(int i=0; i<65; ++i)
    {
        ConvertFromGCR(P, Out_P);
        P += 5;
        Out_P += 4;
    }
    d64_sector_puffer[offset]=convert_puffer[0]; // restore destroyed bytes
    d64_sector_puffer[offset+D64_SECTOR_SIZE+1] = convert_puffer[1];
    d64_sector_puffer[offset+D64_SECTOR_SIZE+2] = convert_puffer[2];
    d64_sector_puffer[offset+D64_SECTOR_SIZE+3] = convert_puffer[3];

    for(int num=0; num<(sector_nr-1); ++num)
    {
        // find track-marker .. FF FF 52 ... FF FF 55
        do
        {
            while(*P++ != GCR_SYNCMARK) { };
            if (*P++ == GCR_SYNCMARK)
            {
                while(*P == GCR_SYNCMARK) { ++P; };
                if (*P == 0x52)
                {
                    break;
                }
            }
        } while(1);
        ConvertFromGCR(P, convert_puffer);
        if ((track_nr+1) != convert_puffer[3])
        {
            return;
        }
        P += 4;
        offset = (int32_t) convert_puffer[2]*D64_SECTOR_SIZE;

        // find sector-marker
        do
        {
            while(*P++ != GCR_SYNCMARK) { };
            if (*P++ == GCR_SYNCMARK)
            {
                while(*P == GCR_SYNCMARK) { ++P; };
                if (*P == 0x55)
                {
                    break;
                }
            }
        } while(1);
        // ----
        convert_puffer[0] = d64_sector_puffer[offset];   // save first byte of the sector
        convert_puffer[1] = d64_sector_puffer[offset+D64_SECTOR_SIZE+1];
        convert_puffer[2] = d64_sector_puffer[offset+D64_SECTOR_SIZE+2];
        convert_puffer[3] = d64_sector_puffer[offset+D64_SECTOR_SIZE+3];
        Out_P = &d64_sector_puffer[offset];
        for(int i=0; i<65; ++i)
        {
            ConvertFromGCR(P, Out_P);
            P += 5;
            Out_P += 4;
        }
        d64_sector_puffer[offset]=convert_puffer[0]; // restore destroyed bytes
        d64_sector_puffer[offset+D64_SECTOR_SIZE+1] = convert_puffer[1];
        d64_sector_puffer[offset+D64_SECTOR_SIZE+2] = convert_puffer[2];
        d64_sector_puffer[offset+D64_SECTOR_SIZE+3] = convert_puffer[3];
    }
}

size_t buffer_to_track(uint8_t* buffer, size_t buffer_len, uint8_t track_nr, uint8_t* last_sector)
{
    size_t      remaining_size = buffer_len;
    uint8_t*    Dest_P;
    uint8_t*    Buffer_P = buffer;
    uint8_t     current_sector, next_sector = 0;
    const uint8_t sector_interleave = (d64_track_zone[track_nr] == 2) ? 11 : 10; // set interleave to 10 by default, 11 for 18sector-tracks
    const uint8_t num_of_sectors = d64_sector_count[d64_track_zone[track_nr]];

    memset(d64_sector_puffer, 0, sizeof(d64_sector_puffer));

    do
    {
        current_sector = next_sector;
        Dest_P = &d64_sector_puffer[1+current_sector*D64_SECTOR_SIZE];
        size_t copy_size = D64_SECTOR_SIZE-2;
        if (remaining_size < copy_size)
        {
            copy_size = remaining_size;
        }
        memcpy(&Dest_P[2], Buffer_P, copy_size);

        remaining_size -= copy_size;
        if (0 == remaining_size)
        {
            Dest_P[1] = copy_size+1;
            break;
        }
        Buffer_P += copy_size;

        next_sector = (current_sector+sector_interleave)%num_of_sectors;
        Dest_P[0] = track_nr+1;
        Dest_P[1] = next_sector;
    } while (0 != next_sector);

    *last_sector = current_sector;

    return remaining_size;
}
