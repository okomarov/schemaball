% SCHEMABALLUNIT Unit tests for schemaball.
classdef schemaballUnit < matlab.unittest.TestCase
    methods (Test)
        % Verify all errors
        function verifyErrorsWarnings(tc)
            tc.verifyError(@() schemaball([],[],[],[],[])                  ,'MATLAB:TooManyInputs')

            tc.verifyError(@() schemaball(1)                               ,'schemaball:validR')
            tc.verifyError(@() schemaball(1:10)                            ,'schemaball:validR')
            tc.verifyError(@() schemaball((1:10)')                         ,'schemaball:validR')
            tc.verifyError(@() schemaball(ones(2,2,2))                     ,'schemaball:validR')
            tc.verifyError(@() schemaball([1 3; 0.2 1])                    ,'schemaball:validR')
            tc.verifyError(@() schemaball(['11';'22'])                     ,'schemaball:validR')
            tc.verifyError(@() schemaball(cell(10))                        ,'schemaball:validR')
            tc.verifyError(@() schemaball(struct)                          ,'schemaball:validR')
            tc.verifyError(@() schemaball(true(10))                        ,'schemaball:validR')
            
            tc.verifyError(@() schemaball([],1:2)                          ,'schemaball:validLbls')
            tc.verifyError(@() schemaball([],{1,2})                        ,'schemaball:validLbls')
            tc.verifyError(@() schemaball([],char(97:147))                 ,'schemaball:validLbls')
            tc.verifyError(@() schemaball([],{'a','b'})                    ,'schemaball:validLbls')
            tc.verifyError(@() schemaball([],['a';'b'])                    ,'schemaball:validLbls')
            tc.verifyError(@() schemaball(rand(4),{'a','b';'c','d'})       ,'schemaball:validLbls')
            tc.verifyError(@() schemaball([],struct)                       ,'schemaball:validLbls')
                        
            tc.verifyError(@() schemaball([],[],1:2)                       ,'schemaball:validCcolor')
            tc.verifyError(@() schemaball([],[],'rgb')                     ,'schemaball:validCcolor')
            tc.verifyError(@() schemaball([],[],{'rgb'})                   ,'schemaball:validCcolor')
            tc.verifyError(@() schemaball([],[],struct)                    ,'schemaball:validCcolor')
            tc.verifyError(@() schemaball([],[],1:4)                       ,'schemaball:validCcolor')
            tc.verifyError(@() schemaball([],[],ones(3))                   ,'schemaball:validCcolor')
            tc.verifyError(@() schemaball([],[],[1;0;1])                   ,'schemaball:validCcolor')
            tc.verifyError(@() schemaball([],[],[20 0 1])                  ,'MATLAB:hg:dt_conv:BadColorValue')
            
            tc.verifyError(@() schemaball([],[],[],1:2)                    ,'schemaball:validNcolor')
            tc.verifyError(@() schemaball([],[],[],'rgb')                  ,'schemaball:validNcolor')
            tc.verifyError(@() schemaball([],[],[],{'rgb'})                ,'schemaball:validNcolor')
            tc.verifyError(@() schemaball([],[],[],struct)                 ,'schemaball:validNcolor')
            tc.verifyError(@() schemaball([],[],[],1:4)                    ,'schemaball:validNcolor')
            tc.verifyError(@() schemaball([],[],[],ones(2,3))              ,'schemaball:validNcolor')
            tc.verifyError(@() schemaball([],[],[],[1;0;1])                ,'schemaball:validNcolor')
        end
    end
end