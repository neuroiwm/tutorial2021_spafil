%%% Author: Seitaro Iwama 
%%% 2021.3
classdef spafil_image
    properties
        imgData
        imgData_fil
        imgData_raw
        K
        S
        NoiseLv
        fil
    end
    
    methods (Access = private)
          function [out,sz_pad] = zeropad(Img,in,M)
            sz_in  = size(in);
            if numel(sz_in) == 2
                sz_in(3)  = 1;
            end
            sz_pad = M-1;
            pad1   = zeros(sz_in(1),sz_pad,sz_in(3));
            out    = [pad1,in,pad1];
            sz_out = size(out);
            pad2   = zeros(sz_pad,sz_out(2),sz_in(3));
            out    = [pad2;out;pad2];
          end
        
           function out = normalize_img(Img,in)
            maxV   = max(in,[],'all');
            minV   = min(in,[],'all');
            in     = (in-minV)./(maxV-minV);
            in     = in * 255;
            out    = uint8(in);
        end
    end
    
    methods (Access = public)
        function Img = addNoise(Img)
            in              = Img.imgData;
            Img.imgData_raw = in;
            
            maxV    = max(in,[],'all');
            in      = in + (maxV * Img.NoiseLv) * randn(size(in));
            Img.imgData = in;
            
        end
        function Img = lapfil(Img)
            in = Img.imgData;
            K  = Img.K;
            if isempty(Img.S)
                S = 1;
            else
                S = Img.S;
            end
            
            K(K<1)  = 2;
            K       = floor(K/2) * 2 + 1;
            M       = ceil(K/2);
            mat_fil = 1 * ones(K,K);
            mat_fil(M,M) = -S;
            
            [in,sz_pad]  = Img.zeropad(in,M);
            sz           = size(in);
            out          = in;
            
            for i = 1+sz_pad : sz(1)-sz_pad
                for j = 1+sz_pad : sz(2)-sz_pad
                    out(i,j,:) = ...
                        sum(in(i-sz_pad:i+sz_pad,j-sz_pad:j+sz_pad,:) .* mat_fil,[1,2]);
                end
            end
            
            Img.imgData_fil = out(1+sz_pad : sz(1)-sz_pad,1+sz_pad : sz(2)-sz_pad,:);
            Img.fil         = mat_fil;
        end
        
         function Img = avefil(Img)
            in = Img.imgData;
            K  = Img.K;
            K(K<1)  = 2;
            K       = floor(K/2) * 2 + 1;
            M       = ceil(K/2);
            mat_fil = 1 * ones(K,K);
            mat_fil(M,M) = 1;
            mat_fil = mat_fil/numel(mat_fil);
            
            [in,sz_pad]  = Img.zeropad(in,M);
            sz           = size(in);
            out          = in;
            
            for i = 1+sz_pad : sz(1)-sz_pad
                for j = 1+sz_pad : sz(2)-sz_pad
                    out(i,j,:) = ...
                        sum(in(i-sz_pad:i+sz_pad,j-sz_pad:j+sz_pad,:) .* mat_fil,[1,2]);
                end
            end
            
            Img.imgData_fil = out(1+sz_pad : sz(1)-sz_pad,1+sz_pad : sz(2)-sz_pad,:);
            Img.fil         = mat_fil;
         end
        
         
        function img_show(Img)
            img1 = Img.imgData;
            img2 = Img.imgData_fil;
            
            figure;
            subplot(1,2,1);
            imshow(normalize_img(Img,img1));
            subplot(1,2,2);
            imshow(normalize_img(Img,img2));
        end
        
        function img_show_gr(Img)
            img1 = Img.imgData;
            img2 = Img.imgData_fil;
            
            figure;
            subplot(1,2,1);
            imshow(rgb2gray(normalize_img(Img,img1)));
            subplot(1,2,2);
            imshow(rgb2gray(normalize_img(Img,img2)));
        end
    end
    
    methods (Access = public)
        function Img = spafil_image(in,K,S,Nlv)
            Img.imgData = in;
            Img.K       = K;
            Img.S       = S;
            Img.NoiseLv = Nlv;
        end
    end
end

